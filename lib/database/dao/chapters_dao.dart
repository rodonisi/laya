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

  /// Watch chapter [chapterId]
  Stream<Chapter> watchChapter(int chapterId) {
    return (select(
          chapters,
        )..where((row) => row.id.equals(chapterId)))
        .watchSingleOrNull()
        .whereNotNull();
  }

  /// Watch pages read for chapter [chapterId]
  Stream<int?> watchPagesRead({required int chapterId}) {
    final query = selectOnly(readingProgress)
      ..where(readingProgress.chapterId.equals(chapterId))
      ..addColumns([readingProgress.pagesRead]);

    return query.watchSingleOrNull().map(
      (row) => row?.read(readingProgress.pagesRead),
    );
  }

  /// Watch cover for chapter [chapterId]. Returns null if no cover is present
  Stream<ChapterCover?> watchChapterCover({required int chapterId}) {
    return (select(
      chapterCovers,
    )..where((row) => row.chapterId.equals(chapterId))).watchSingleOrNull();
  }

  /// Get the list chapter ids missing a cover
  Future<List<int>> getMissingCovers() async {
    final query = select(chapters).join([
      leftOuterJoin(
        chapterCovers,
        chapterCovers.chapterId.equalsExp(chapters.id),
      ),
    ]);

    query.where(chapterCovers.chapterId.isNull());

    return await query.map((row) => row.readTable(chapters).id).get();
  }

  /// Upsert a batch of chapters
  Future<void> upsertChapterBatch(Iterable<ChaptersCompanion> entries) async {
    log.d('upserting chapter batch with ${entries.length} entries');
    await batch((batch) {
      batch.insertAllOnConflictUpdate(chapters, entries);
    });
  }

  /// Upsert a chapter cover
  Future<void> upsertChapterCover(ChapterCoversCompanion cover) async {
    await into(chapterCovers).insertOnConflictUpdate(cover);
  }
}
