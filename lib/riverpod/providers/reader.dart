import 'package:fluvita/models/chapter_model.dart';
import 'package:fluvita/models/progress_model.dart';
import 'package:fluvita/riverpod/providers/connectivity.dart';
import 'package:fluvita/riverpod/repository/download_repository.dart';
import 'package:fluvita/riverpod/repository/reader_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reader.g.dart';

@riverpod
/// Wheter the [seriesId] can be currently read in the current state.
/// Returns false if there is no connectivity and the continue point is
/// not downloaded.
Stream<bool> canReadSeries(Ref ref, int seriesId) {
  final hasConnection = ref.watch(hasConnectionProvider).value ?? false;

  final chapter = ref
      .watch(continuePointStreamProvider(seriesId: seriesId))
      .value;

  if (chapter == null) return Stream.value(hasConnection);

  final repo = ref.watch(downloadRepositoryProvider);

  return repo
      .watchIsChapterDownloaded(chapterId: chapter.id)
      .map((isDownloaded) => isDownloaded || hasConnection);
}

@riverpod
/// Fetch continue point for [seriesId] asynchronously. Guarantees a value
/// is returned and does not update until manually invalidated or disposed.
Future<ChapterModel> continuePoint(Ref ref, {required int seriesId}) async {
  final repo = ref.watch(readerRepositoryProvider);
  return await repo.getContinuePoint(seriesId: seriesId);
}

@riverpod
/// Watch continue point for [seriesId], reacting to changes automatically.
Stream<ChapterModel> continuePointStream(
  Ref ref, {
  required int seriesId,
}) async* {
  final repo = ref.watch(readerRepositoryProvider);
  yield* repo.watchContinuePoint(seriesId: seriesId);
}

@riverpod
/// Watch the progress of the continue point for the given [seriesId]
Stream<double> continuePointProgress(Ref ref, {required int seriesId}) async* {
  final repo = ref.watch(readerRepositoryProvider);
  yield* repo.watchContinuePointProgress(seriesId: seriesId).distinct();
}

@riverpod
Future<ProgressModel?> bookProgress(Ref ref, {required int chapterId}) async {
  final repo = ref.watch(readerRepositoryProvider);
  return await repo.getProgress(chapterId);
}

@riverpod
Stream<int?> prevChapter(
  Ref ref, {
  int? seriesId,
  int? volumeId,
  int? chapterId,
}) async* {
  if (seriesId == null || chapterId == null) {
    yield null;
    return;
  }
  final repo = ref.watch(readerRepositoryProvider);
  yield* repo
      .watchPrevChapterId(
        seriesId: seriesId,
        volumeId: volumeId,
        chapterId: chapterId,
      )
      .distinct();
}

@riverpod
Stream<int?> nextChapter(
  Ref ref, {
  int? seriesId,
  int? volumeId,
  int? chapterId,
}) async* {
  if (seriesId == null || chapterId == null) {
    yield null;
    return;
  }
  final repo = ref.watch(readerRepositoryProvider);
  yield* repo
      .watchNextChapterId(
        seriesId: seriesId,
        volumeId: volumeId,
        chapterId: chapterId,
      )
      .distinct();
}

@riverpod
class MarkSeriesRead extends _$MarkSeriesRead {
  @override
  void build({required int seriesId}) {}

  Future<void> markRead() async {
    final repo = ref.read(readerRepositoryProvider);
    await repo.markSeriesRead(seriesId);
  }

  Future<void> markUnread() async {
    final repo = ref.read(readerRepositoryProvider);
    await repo.markSeriesUnread(seriesId);
  }
}

@riverpod
class MarkVolumeRead extends _$MarkVolumeRead {
  @override
  void build({required int seriesId, required int volumeId}) {}

  Future<void> markRead() async {
    final repo = ref.read(readerRepositoryProvider);
    await repo.markVolumeRead(seriesId, volumeId);
  }

  Future<void> markUnread() async {
    final repo = ref.read(readerRepositoryProvider);
    await repo.markVolumeUnread(seriesId, volumeId);
  }
}

@riverpod
class MarkChapterRead extends _$MarkChapterRead {
  @override
  void build({required int seriesId, required int chapterId}) {}

  Future<void> markRead() async {
    final repo = ref.read(readerRepositoryProvider);
    await repo.markChapterRead(seriesId, chapterId);
  }

  Future<void> markUnread() async {
    final repo = ref.read(readerRepositoryProvider);
    await repo.markChapterUnread(seriesId, chapterId);
  }
}
