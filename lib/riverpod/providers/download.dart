import 'package:fluvita/riverpod/repository/download_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download.g.dart';

/// Whether every page of [chapterId] is stored locally
@riverpod
Stream<bool> chapterDownloaded(
  Ref ref, {
  required int chapterId,
}) {
  final repo = ref.watch(downloadRepositoryProvider);
  return repo.watchIsChapterDownloaded(chapterId: chapterId).distinct();
}

/// The download progress percent for chapter [chapterId]
@riverpod
Stream<double> chapterDownloadProgress(
  Ref ref, {
  required int chapterId,
}) {
  final repo = ref.watch(downloadRepositoryProvider);
  return repo.watchDownloadProgress(chapterId: chapterId).distinct();
}

/// Emits download progress percent for volume [volumeId]
@riverpod
Stream<double> volumeDownloadProgress(
  Ref ref, {
  required int volumeId,
}) {
  final repo = ref.watch(downloadRepositoryProvider);
  return repo.watchVolumeDownloadProgress(volumeId: volumeId).distinct();
}

/// Emits total download progress percent for all chapters belonging to series [seriesId]
@riverpod
Stream<double> seriesDownloadProgress(
  Ref ref, {
  required int seriesId,
}) {
  final repo = ref.watch(downloadRepositoryProvider);
  return repo.watchSeriesDownloadProgress(seriesId: seriesId).distinct();
}
