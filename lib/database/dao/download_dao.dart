import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/chapters.dart';
import 'package:fluvita/database/tables/download.dart';

part 'download_dao.g.dart';

@DriftAccessor(tables: [DownloadedPages, Chapters])
class DownloadDao extends DatabaseAccessor<AppDatabase>
    with _$DownloadDaoMixin {
  DownloadDao(super.attachedDatabase);

  /// Returns whether ALL pages of a chapter are stored locally.
  ///
  /// Drives from the `chapters` table (always one row) and LEFT JOINs
  /// `downloadedPages` so the result is never empty, even before any page
  /// has been saved.
  SingleSelectable<bool> isChapterDownloaded({required int chapterId}) {
    final downloadedCount = downloadedPages.chapterId.count();

    final query = selectOnly(chapters)
      ..addColumns([chapters.pages, downloadedCount])
      ..where(chapters.id.equals(chapterId));

    query.join([
      leftOuterJoin(
        downloadedPages,
        downloadedPages.chapterId.equalsExp(chapters.id),
        useColumns: false,
      ),
    ]);

    return query.map((row) {
      final total = row.read(chapters.pages) ?? 0;
      final downloaded = row.read(downloadedCount) ?? 0;
      return total > 0 && downloaded >= total;
    });
  }

  /// Returns how many pages have been downloaded for a chapter.
  SingleSelectable<int> totalDownloadedPages({required int chapterId}) {
    final countColumn = downloadedPages.chapterId.count();

    final query = selectOnly(downloadedPages)
      ..addColumns([countColumn])
      ..where(downloadedPages.chapterId.equals(chapterId));

    return query.map((row) => row.read(countColumn) ?? 0);
  }

  /// Fetches a specific page blob by chapterId + page index.
  SingleSelectable<DownloadedPage> getPage({
    required int chapterId,
    required int page,
  }) {
    return managers.downloadedPages.filter(
      (f) => f.chapterId.id(chapterId) & f.page(page),
    );
  }

  /// Persists a single page blob. Replaces any existing entry for the same
  /// (chapterId, page) composite key.
  Future<void> insertPage(DownloadedPagesCompanion entry) {
    return into(downloadedPages).insertOnConflictUpdate(entry);
  }

  /// Deletes all downloaded pages for a chapter.
  Future<void> deleteChapter({required int chapterId}) {
    return managers.downloadedPages
        .filter((f) => f.chapterId.id(chapterId))
        .delete();
  }

  // ---------------------------------------------------------------------------
  // Volume / series batch progress queries
  // ---------------------------------------------------------------------------

  /// Reactively emits the number of fully-downloaded chapters whose IDs are in
  /// [chapterIds]. "Fully downloaded" means `COUNT(downloaded_pages) >= chapters.pages`.
  ///
  /// Returns 0 when [chapterIds] is empty.
  Stream<int> watchDownloadedChapterCountByIds({
    required List<int> chapterIds,
  }) {
    if (chapterIds.isEmpty) return Stream.value(0);

    final downloadedCount = downloadedPages.chapterId.count();
    final query = selectOnly(chapters)
      ..addColumns([chapters.id, chapters.pages, downloadedCount])
      ..where(chapters.id.isIn(chapterIds));

    query.join([
      leftOuterJoin(
        downloadedPages,
        downloadedPages.chapterId.equalsExp(chapters.id),
        useColumns: false,
      ),
    ]);

    query.groupBy([chapters.id, chapters.pages]);

    return query.watch().map((rows) {
      var fullyDownloaded = 0;
      for (final row in rows) {
        final total = row.read(chapters.pages) ?? 0;
        final downloaded = row.read(downloadedCount) ?? 0;
        if (total > 0 && downloaded >= total) fullyDownloaded++;
      }
      return fullyDownloaded;
    });
  }

  /// Reactively emits the number of fully-downloaded chapters for [seriesId].
  Stream<int> watchDownloadedChapterCountBySeries({required int seriesId}) {
    final downloadedCount = downloadedPages.chapterId.count();
    final query = selectOnly(chapters)
      ..addColumns([chapters.id, chapters.pages, downloadedCount])
      ..where(chapters.seriesId.equals(seriesId));

    query.join([
      leftOuterJoin(
        downloadedPages,
        downloadedPages.chapterId.equalsExp(chapters.id),
        useColumns: false,
      ),
    ]);

    query.groupBy([chapters.id, chapters.pages]);

    return query.watch().map((rows) {
      var fullyDownloaded = 0;
      for (final row in rows) {
        final total = row.read(chapters.pages) ?? 0;
        final downloaded = row.read(downloadedCount) ?? 0;
        if (total > 0 && downloaded >= total) fullyDownloaded++;
      }
      return fullyDownloaded;
    });
  }

  /// Reactively emits the total number of chapters for [seriesId].
  Stream<int> watchTotalChapterCountBySeries({required int seriesId}) {
    final countCol = chapters.id.count();
    final query = selectOnly(chapters)
      ..addColumns([countCol])
      ..where(chapters.seriesId.equals(seriesId));

    return query.watchSingle().map((row) => row.read(countCol) ?? 0);
  }
}
