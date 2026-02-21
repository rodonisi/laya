import 'package:fluvita/riverpod/repository/download_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download.g.dart';

/// Whether every page of [chapterId] is stored locally.
@riverpod
Stream<bool> chapterDownloaded(
  Ref ref, {
  required int chapterId,
}) {
  final repo = ref.watch(downloadRepositoryProvider);
  return repo.watchIsChapterDownloaded(chapterId: chapterId);
}

/// Number of pages currently stored for [chapterId].
/// Combine with the chapter's total page count to derive a progress ratio.
@riverpod
Stream<int> chapterDownloadedPageCount(
  Ref ref, {
  required int chapterId,
}) {
  final repo = ref.watch(downloadRepositoryProvider);
  return repo.watchDownloadedPageCount(chapterId: chapterId);
}

/// Emits `({downloaded, total})` for a volume identified by its chapter IDs.
///
/// [chapterIds] must be a stable sorted list (list identity is used for
/// provider caching).
@riverpod
Stream<({int downloaded, int total})> volumeDownloadProgress(
  Ref ref, {
  required List<int> chapterIds,
}) {
  final repo = ref.watch(downloadRepositoryProvider);
  return repo.watchVolumeDownloadProgress(chapterIds: chapterIds);
}

/// Emits `({downloaded, total})` for every chapter belonging to [seriesId].
@riverpod
Stream<({int downloaded, int total})> seriesDownloadProgress(
  Ref ref, {
  required int seriesId,
}) {
  final repo = ref.watch(downloadRepositoryProvider);
  return repo.watchSeriesDownloadProgress(seriesId: seriesId);
}

