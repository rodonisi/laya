import 'dart:async';

import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/converters/page_content_converter.dart';
import 'package:fluvita/riverpod/providers/client.dart';
import 'package:fluvita/riverpod/repository/book_repository.dart';
import 'package:fluvita/riverpod/repository/chapters_repository.dart';
import 'package:fluvita/riverpod/repository/database.dart';
import 'package:fluvita/riverpod/settings.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_repository.g.dart';

@riverpod
DownloadRepository downloadRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final client = ref.watch(restClientProvider);
  final apiKey = ref.watch(apiKeyProvider);

  return DownloadRepository(
    db: db,
    bookClient: BookRemoteOperations(client: client, apiKey: apiKey!),
    chapterClient: ChapterRemoteOperations(client: client, apiKey: apiKey),
  );
}

class DownloadRepository {
  final AppDatabase _db;
  final BookRemoteOperations _bookClient;
  final ChapterRemoteOperations _chapterClient;

  /// Tracks active download tasks so duplicate calls are ignored.
  final Map<int, _DownloadTask> _active = {};

  DownloadRepository({
    required AppDatabase db,
    required BookRemoteOperations bookClient,
    required ChapterRemoteOperations chapterClient,
  }) : _db = db,
       _bookClient = bookClient,
       _chapterClient = chapterClient;

  // ---------------------------------------------------------------------------
  // Queries / streams
  // ---------------------------------------------------------------------------

  /// Whether every page of [chapterId] is persisted locally.
  Future<bool> isChapterDownloaded({required int chapterId}) {
    return _db.downloadDao
        .isChapterDownloaded(chapterId: chapterId)
        .getSingle();
  }

  /// Reactive stream of the full-download flag. Suitable for driving UI.
  Stream<bool> watchIsChapterDownloaded({required int chapterId}) {
    return _db.downloadDao
        .isChapterDownloaded(chapterId: chapterId)
        .watchSingle();
  }

  /// Emits the number of pages currently stored for [chapterId].
  /// Pair with the total page count from the chapter model for a progress ratio.
  Stream<int> watchDownloadedPageCount({required int chapterId}) {
    return _db.downloadDao
        .totalDownloadedPages(chapterId: chapterId)
        .watchSingle();
  }

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  /// Downloads every page of [chapterId] and persists the blobs to the DB.
  ///
  /// - If a download for this chapter is already running, the call is a no-op.
  /// - Progress is observable via [watchDownloadedPageCount].
  /// - Any page that is already stored in the DB is skipped so that partial
  ///   downloads can be resumed.
  Future<void> downloadChapter({required int chapterId}) async {
    if (_active.containsKey(chapterId)) {
      log.d('download already in progress for chapter $chapterId');
      return;
    }

    final task = _DownloadTask();
    _active[chapterId] = task;

    try {
      // Resolve chapter metadata (page count, format).
      final chapter = await _chapterClient.getChapter(chapterId);
      final totalPages = chapter.pages.value;
      final format = chapter.format.value;

      if (totalPages == 0) {
        throw Exception('Chapter $chapterId has no pages to download');
      }

      log.d(
        'starting download: chapter=$chapterId format=$format pages=$totalPages',
      );

      // Resume support: find how many pages are already in the DB.
      final resumeFrom = await _db.downloadDao
          .totalDownloadedPages(chapterId: chapterId)
          .getSingle();

      for (var page = resumeFrom; page < totalPages; page++) {
        if (task.cancelled) break;

        log.d('downloading page $page/$totalPages of chapter $chapterId');

        final Uint8List blob = switch (format) {
          .epub => pageContentConverter.toSql(
            await _bookClient.getPageContent(chapterId: chapterId, page: page),
          ),
          .archive => await _bookClient.getImagePage(
            chapterId: chapterId,
            page: page,
          ),
          _ => throw Exception('unsupported format'),
        };

        await _db.downloadDao.insertPage(
          DownloadedPagesCompanion.insert(
            chapterId: chapterId,
            page: page,
            data: blob,
            lastSync: Value(DateTime.timestamp()),
          ),
        );
      }

      log.d(
        task.cancelled
            ? 'download cancelled: chapter $chapterId'
            : 'download complete: chapter $chapterId',
      );
    } catch (e, st) {
      log.e('download failed for chapter $chapterId', error: e, stackTrace: st);
      rethrow;
    } finally {
      _active.remove(chapterId);
    }
  }

  /// Cancels an in-progress download for [chapterId].
  ///
  /// Already-persisted pages are kept; the partial download can be resumed
  /// by calling [downloadChapter] again.
  void cancelDownload({required int chapterId}) {
    _active[chapterId]?.cancel();
  }

  /// Removes all locally stored pages for [chapterId].
  Future<void> deleteChapter({required int chapterId}) async {
    cancelDownload(chapterId: chapterId);
    await _db.downloadDao.deleteChapter(chapterId: chapterId);
    log.d('deleted local pages for chapter $chapterId');
  }

  // ---------------------------------------------------------------------------
  // Volume batch operations
  // ---------------------------------------------------------------------------

  /// Emits the download progress as a percentage for all chapters belonging to
  /// [volumeId].
  Stream<double> watchVolumeDownloadProgress({
    required int volumeId,
  }) {
    return _db.downloadDao.watchDownloadedProgressByVolume(
      volumeId: volumeId,
    );
  }

  /// Downloads every chapter in [chapterIds] sequentially.
  Future<void> downloadVolume({required List<int> chapterIds}) async {
    for (final id in chapterIds) {
      await downloadChapter(chapterId: id);
    }
  }

  /// Cancels and deletes all downloaded pages for the chapters in [chapterIds].
  Future<void> deleteVolume({required int volumeId}) async {
    await _db.downloadDao.deleteVolume(volumeId: volumeId);
  }

  // ---------------------------------------------------------------------------
  // Series batch operations
  // ---------------------------------------------------------------------------

  /// Emits the download progress as a percentage for all chapters belonging to [seriesId].
  Stream<double> watchSeriesDownloadProgress({
    required int seriesId,
  }) {
    return _db.downloadDao.watchDownloadedProgressBySeries(seriesId: seriesId);
  }

  /// Downloads every chapter in [seriesId] sequentially, querying chapter IDs
  /// from the DB.
  Future<void> downloadSeries({required int seriesId}) async {
    final chapters = await _db.seriesDao.allChapters(seriesId: seriesId).get();
    for (final chapter in chapters) {
      await downloadChapter(chapterId: chapter.id);
    }
  }

  /// Cancels and deletes all downloaded pages for every chapter in [seriesId].
  Future<void> deleteSeries({required int seriesId}) async {
    await _db.downloadDao.deleteSeries(seriesId: seriesId);
  }
}

/// Lightweight handle used to signal cancellation to a running download loop.
class _DownloadTask {
  bool cancelled = false;
  void cancel() => cancelled = true;
}
