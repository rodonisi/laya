import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/chapters.dart';
import 'package:fluvita/database/tables/progress.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:stream_transform/stream_transform.dart';

part 'chapters_dao.g.dart';

@DriftAccessor(tables: [Chapters, ChapterCovers, ReadingProgress])
class ChaptersDao extends DatabaseAccessor<AppDatabase>
    with _$ChaptersDaoMixin {
  ChaptersDao(super.attachedDatabase);

  Stream<Chapter> watchChapter(int chapterId) {
    return (select(
          chapters,
        )..where((row) => row.id.equals(chapterId)))
        .watchSingleOrNull()
        .whereNotNull();
  }

  Stream<int?> watchPagesRead({required int chapterId}) {
    final query = selectOnly(readingProgress)
      ..where(readingProgress.chapterId.equals(chapterId))
      ..addColumns([readingProgress.pagesRead]);

    return query.watchSingleOrNull().map(
      (row) => row?.read(readingProgress.pagesRead),
    );
  }

  Stream<ChapterCover> watchChapterCover({required int chapterId}) {
    return (select(
          chapterCovers,
        )..where((row) => row.chapterId.equals(chapterId)))
        .watchSingleOrNull()
        .whereNotNull()
        .distinct();
  }

  Future<void> upsertChapter(ChaptersCompanion chapter) async {
    await into(chapters).insertOnConflictUpdate(chapter);
  }

  Future<void> upsertChapterBatch(Iterable<ChaptersCompanion> entries) async {
    log.d('upserting chapter batch with ${entries.length} entries');
    await batch((batch) {
      batch.insertAllOnConflictUpdate(chapters, entries);
    });
  }

  Future<void> upsertChapterCover(ChapterCoversCompanion cover) async {
    await into(chapterCovers).insertOnConflictUpdate(cover);
  }

  Future<void> clearSeriesChapters({required int seriesId}) async {
    await (delete(
      chapters,
    )..where((row) => row.seriesId.equals(seriesId))).go();
  }
}
