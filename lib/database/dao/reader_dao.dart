import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/chapters.dart';
import 'package:fluvita/database/tables/progress.dart';
import 'package:fluvita/database/tables/series.dart';
import 'package:fluvita/utils/logging.dart';

part 'reader_dao.g.dart';

@DriftAccessor(tables: [Series, Chapters, ReadingProgress])
class ReaderDao extends DatabaseAccessor<AppDatabase> with _$ReaderDaoMixin {
  ReaderDao(super.attachedDatabase);

  JoinedSelectStatement<HasResultSet, dynamic> continuePointQuery({
    required int seriesId,
  }) {
    return select(chapters).join([
        leftOuterJoin(
          readingProgress,
          readingProgress.chapterId.equalsExp(chapters.id),
        ),
      ])
      ..where(chapters.seriesId.equals(seriesId))
      ..orderBy([
        OrderingTerm.desc(
          readingProgress.chapterId.isNotNull() &
              readingProgress.pagesRead.isBiggerThan(const Constant(0)) &
              readingProgress.pagesRead.isSmallerThan(chapters.pages),
        ),
        OrderingTerm.desc(
          readingProgress.chapterId.isNull() |
              readingProgress.pagesRead.equals(0),
        ),
        OrderingTerm.asc(chapters.sortOrder),
      ])
      ..limit(1);
  }

  Future<Chapter> getContinuePoint({required int seriesId}) {
    return continuePointQuery(
      seriesId: seriesId,
    ).map((row) => row.readTable(chapters)).getSingle();
  }

  Stream<double> watchContinuePointProgress({required int seriesId}) {
    return continuePointQuery(seriesId: seriesId).watchSingleOrNull().map((
      row,
    ) {
      if (row == null) return 0.0;
      final chapter = row.readTable(chapters);
      final progress = row.readTableOrNull(readingProgress);
      if (progress == null || chapter.pages == 0) return 0.0;
      return progress.pagesRead / chapter.pages;
    });
  }

  Future<ReadingProgressData?> getProgress(int chapterId) {
    return (select(
      readingProgress,
    )..where((row) => row.chapterId.equals(chapterId))).getSingleOrNull();
  }

  Future<List<ReadingProgressData>> getDirtyProgress() async {
    return await managers.readingProgress.filter((f) => f.dirty(true)).get();
  }

  Future<void> upsertProgress(ReadingProgressCompanion entry) async {
    log.d('upsert progress chapter=${entry.chapterId.value}');
    await into(readingProgress).insertOnConflictUpdate(entry);
  }

  Future<void> mergeProgress(ReadingProgressCompanion incoming) async {
    await transaction(() async {
      final local =
          await (select(
                readingProgress,
              )..where((tbl) => tbl.chapterId.equals(incoming.chapterId.value)))
              .getSingleOrNull();

      final localWins =
          local != null &&
          local.dirty &&
          local.lastModified.isAfter(incoming.lastModified.value);

      if (!localWins) {
        await into(readingProgress).insertOnConflictUpdate(incoming);
      }
    });
  }

  Future<void> upsertProgressBatch(
    Iterable<ReadingProgressCompanion> incoming,
  ) async {
    await batch(
      (batch) => batch.insertAllOnConflictUpdate(readingProgress, incoming),
    );
  }

  /// Upsert chapter progress batch only where the existing progress is not
  /// dirty
  Future<void> upsertCleanProgressBatch(
    Iterable<ReadingProgressCompanion> incoming,
  ) async {
    await transaction(() async {
      if (incoming.isEmpty) return;

      final ids = incoming.map((e) => e.chapterId.value).toList();

      final existing = {
        for (final row in await (select(
          readingProgress,
        )..where((r) => r.chapterId.isIn(ids))).get())
          row.chapterId: row,
      };

      final toWrite = <ReadingProgressCompanion>[];
      for (final entry in incoming) {
        final local = existing[entry.chapterId.value];

        final localWins = local != null && local.dirty;

        if (!localWins) {
          toWrite.add(entry);
        }
      }

      log.d('upserting progress batch with ${toWrite.length} entries');
      await batch((b) => b.insertAllOnConflictUpdate(readingProgress, toWrite));
    });
  }

  Stream<Chapter?> watchPrevChapter({
    required int seriesId,
    int? volumeId,
    required int chapterId,
  }) {
    final sortOrderOfCurrent = subqueryExpression<double>(
      selectOnly(chapters)
        ..addColumns([chapters.sortOrder])
        ..where(chapters.id.equals(chapterId)),
    );

    final query = select(chapters)
      ..where((c) {
        final base =
            c.seriesId.equals(seriesId) &
            c.sortOrder.isSmallerThan(sortOrderOfCurrent);
        return volumeId != null ? base & c.volumeId.equals(volumeId) : base;
      })
      ..orderBy([(c) => OrderingTerm.desc(c.sortOrder)])
      ..limit(1);

    return query.watchSingleOrNull();
  }

  Stream<Chapter?> watchNextChapter({
    required int seriesId,
    int? volumeId,
    required int chapterId,
  }) {
    final sortOrderOfCurrent = subqueryExpression<double>(
      selectOnly(chapters)
        ..addColumns([chapters.sortOrder])
        ..where(chapters.id.equals(chapterId)),
    );

    final query = select(chapters)
      ..where((c) {
        final base =
            c.seriesId.equals(seriesId) &
            c.sortOrder.isBiggerThan(sortOrderOfCurrent);
        return volumeId != null ? base & c.volumeId.equals(volumeId) : base;
      })
      ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])
      ..limit(1);

    return query.watchSingleOrNull();
  }

  Future<void> markSeriesRead(int seriesId, {required bool isRead}) async {
    await transaction(() async {
      await (update(
        readingProgress,
      )..where((row) => row.seriesId.equals(seriesId))).write(
        ReadingProgressCompanion.custom(
          totalReads: readingProgress.totalReads + const Constant(1),
        ),
      );

      final query =
          (select(
            chapters,
          )..where((row) => row.seriesId.equals(seriesId))).join([
            innerJoin(series, series.id.equalsExp(chapters.seriesId)),
          ]);

      final progressBatch = (await query.get()).map((join) {
        final c = join.readTable(chapters);
        final s = join.readTable(series);

        return ReadingProgressCompanion(
          chapterId: Value(c.id),
          volumeId: Value(c.volumeId),
          seriesId: Value(s.id),
          libraryId: Value(s.libraryId),
          pagesRead: Value(isRead ? c.pages : 0),
          dirty: const Value(true),
          // totalReads will already be incremented from step 1
        );
      });

      await batch((batch) {
        batch.insertAllOnConflictUpdate(readingProgress, progressBatch);
      });
    });
  }

  Future<void> markVolumeRead(
    int seriesId,
    int volumeId, {
    required bool isRead,
  }) async {
    await transaction(() async {
      await (update(
            readingProgress,
          )..where(
            (tbl) =>
                tbl.seriesId.equals(seriesId) & tbl.volumeId.equals(volumeId),
          ))
          .write(
            ReadingProgressCompanion.custom(
              totalReads: readingProgress.totalReads + const Constant(1),
            ),
          );

      final query =
          (select(
                chapters,
              )..where(
                (row) =>
                    row.seriesId.equals(seriesId) &
                    row.volumeId.equals(volumeId),
              ))
              .join([
                innerJoin(series, series.id.equalsExp(chapters.seriesId)),
              ]);

      final progressBatch = (await query.get()).map((join) {
        final c = join.readTable(chapters);
        final s = join.readTable(series);

        return ReadingProgressCompanion(
          chapterId: Value(c.id),
          volumeId: Value(c.volumeId),
          seriesId: Value(s.id),
          libraryId: Value(s.libraryId),
          pagesRead: Value(isRead ? c.pages : 0),
          dirty: const Value(true),
          // totalReads will already be incremented from step 1
        );
      });

      await batch((batch) {
        batch.insertAllOnConflictUpdate(readingProgress, progressBatch);
      });
    });
  }

  Future<void> markChapterRead(int chapterId, {required bool isRead}) async {
    await transaction(() async {
      (update(
        readingProgress,
      )..where((tbl) => tbl.chapterId.equals(chapterId))).write(
        ReadingProgressCompanion.custom(
          totalReads: readingProgress.totalReads + const Constant(1),
        ),
      );

      final join =
          await (select(
            chapters,
          )..where((tbl) => tbl.id.equals(chapterId))).join([
            innerJoin(series, series.id.equalsExp(chapters.seriesId)),
          ]).getSingle();

      final c = join.readTable(chapters);
      final s = join.readTable(series);

      await into(
        readingProgress,
      ).insertOnConflictUpdate(
        ReadingProgressCompanion(
          chapterId: Value(c.id),
          volumeId: Value(c.volumeId),
          seriesId: Value(s.id),
          libraryId: Value(s.libraryId),
          pagesRead: Value(isRead ? c.pages : 0),
          dirty: const Value(true),
        ),
      );
    });
  }
}
