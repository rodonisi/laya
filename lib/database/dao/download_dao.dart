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
  Future<void> insertPage({
    required int chapterId,
    required int page,
    required Uint8List data,
  }) {
    return into(downloadedPages).insertOnConflictUpdate(
      DownloadedPagesCompanion(
        chapterId: Value(chapterId),
        page: Value(page),
        data: Value(data),
        lastSync: Value(DateTime.now()),
      ),
    );
  }

  /// Deletes all downloaded pages for a chapter.
  Future<void> deleteChapter({required int chapterId}) {
    return managers.downloadedPages
        .filter((f) => f.chapterId.id(chapterId))
        .delete();
  }
}
