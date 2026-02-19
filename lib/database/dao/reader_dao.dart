import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/chapters.dart';
import 'package:fluvita/database/tables/continue_point.dart';
import 'package:fluvita/database/tables/progress.dart';
import 'package:fluvita/database/tables/series.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:stream_transform/stream_transform.dart';

part 'reader_dao.g.dart';

@DriftAccessor(tables: [Series, Chapters, ContinuePoints, ReadingProgress])
class ReaderDao extends DatabaseAccessor<AppDatabase> with _$ReaderDaoMixin {
  ReaderDao(super.attachedDatabase);

  Stream<Chapter> continuePoint({required int seriesId}) {
    final query = select(continuePoints).join([
      innerJoin(
        chapters,
        chapters.id.equalsExp(continuePoints.chapterId),
      ),
    ])..where(continuePoints.seriesId.equals(seriesId));

    return query
        .watchSingleOrNull()
        .map((row) => row?.readTable(chapters))
        .whereNotNull();
  }

  Future<void> upsertContinuePoint(ContinuePointsCompanion entry) async {
    log.d('upsert continue point $entry');
    await into(continuePoints).insertOnConflictUpdate(entry);
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
    final query = update(chapters)
      ..where((tbl) => tbl.seriesId.equals(seriesId));

    if (isRead) {
      await query.write(
        ChaptersCompanion.custom(
          pagesRead: chapters.pages,
        ),
      );
    } else {
      await query.write(
        const ChaptersCompanion(pagesRead: Value(0)),
      );
    }
  }

  Future<void> markVolumeRead(
    int seriesId,
    int volumeId, {
    required bool isRead,
  }) async {
    final query = update(chapters)
      ..where(
        (tbl) => tbl.seriesId.equals(seriesId) & tbl.volumeId.equals(volumeId),
      );

    final volumeQuery = update(volumes)
      ..where((tbl) => tbl.seriesId.equals(seriesId) & tbl.id.equals(volumeId));

    await query.write(
      isRead
          ? ChaptersCompanion.custom(pagesRead: chapters.pages)
          : const ChaptersCompanion(pagesRead: Value(0)),
    );

    await volumeQuery.write(
      isRead
          ? VolumesCompanion.custom(pagesRead: volumes.pages)
          : const VolumesCompanion(pagesRead: Value(0)),
    );
  }

  Future<void> markChapterRead(int chapterId, {required bool isRead}) async {
    final query = update(chapters)..where((tbl) => tbl.id.equals(chapterId));

    await query.write(
      isRead
          ? ChaptersCompanion.custom(pagesRead: chapters.pages)
          : const ChaptersCompanion(pagesRead: Value(0)),
    );
  }
}
