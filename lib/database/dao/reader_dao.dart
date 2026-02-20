import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/chapters.dart';
import 'package:fluvita/database/tables/progress.dart';
import 'package:fluvita/database/tables/series.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:stream_transform/stream_transform.dart';

part 'reader_dao.g.dart';

@DriftAccessor(tables: [Series, Chapters, ContinuePoints, ReadingProgress])
class ReaderDao extends DatabaseAccessor<AppDatabase> with _$ReaderDaoMixin {
  ReaderDao(super.attachedDatabase);

  Stream<Chapter> watchContinuePoint({required int seriesId}) {
    final query = select(continuePoints).join([
      innerJoin(
        chapters,
        chapters.id.equalsExp(continuePoints.chapterId),
      ),
    ])..where(continuePoints.seriesId.equals(seriesId));

    return query
        .map((res) => res.readTable(chapters))
        .watchSingleOrNull()
        .whereNotNull();
  }

  Stream<double> watchContinuePointProgress({required int seriesId}) {
    final query = select(continuePoints).join([
      innerJoin(
        chapters,
        chapters.id.equalsExp(continuePoints.chapterId),
      ),
      innerJoin(
        readingProgress,
        readingProgress.chapterId.equalsExp(continuePoints.chapterId),
      ),
    ])..where(continuePoints.seriesId.equals(seriesId));

    return query.watchSingleOrNull().whereNotNull().map((row) {
      final progress = row.readTable(readingProgress);
      final chapter = row.readTable(chapters);

      if (chapter.pages == 0) return 0.0;
      return progress.pagesRead / chapter.pages;
    });
  }

  Future<void> upsertContinuePoint(ContinuePointsCompanion entry) async {
    log.d('upsert continue point $entry');
    await into(continuePoints).insertOnConflictUpdate(entry);
  }

  Future<void> upsertContinuePointBatch(
    Iterable<ContinuePointsCompanion> incoming,
  ) async {
    await batch(
      (batch) => batch.insertAllOnConflictUpdate(continuePoints, incoming),
    );
  }

  Stream<ReadingProgressData?> watchProgress(int chapterId) {
    return (select(
      readingProgress,
    )..where((row) => row.chapterId.equals(chapterId))).watchSingleOrNull();
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

  Future<void> mergeProgressBatch(
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

        final localWins =
            local != null &&
            local.dirty &&
            (!entry.lastModified.present ||
                local.lastModified.isAfter(entry.lastModified.value));

        if (!localWins) {
          toWrite.add(entry);
        }
      }

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
