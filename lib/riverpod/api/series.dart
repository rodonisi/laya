import 'package:fluvita/models/image_model.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/riverpod/repository/series_metadata_repository.dart';
import 'package:fluvita/riverpod/repository/series_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'series.g.dart';

@riverpod
Stream<SeriesModel> series(Ref ref, {required int seriesId}) async* {
  final repo = ref.watch(seriesRepositoryProvider);
  yield* repo.watchSeries(seriesId);
}

@riverpod
Stream<ImageModel> seriesCover(Ref ref, {required int seriesId}) async* {
  final repo = ref.watch(seriesRepositoryProvider);
  yield* repo.watchSeriesCover(seriesId);
}

@riverpod
Stream<List<SeriesModel>> allSeries(Ref ref, {int? libraryId}) async* {
  final repo = ref.watch(seriesRepositoryProvider);
  yield* repo.watchAllSeries(libraryId: libraryId);
}

@riverpod
Stream<SeriesDetailModel> seriesDetail(
  Ref ref, {
  required int seriesId,
}) async* {
  final repo = ref.watch(seriesRepositoryProvider);
  yield* repo.watchSeriesDetails(seriesId);
}

@riverpod
Stream<SeriesMetadataModel> seriesMetadata(
  Ref ref, {
  required int seriesId,
}) async* {
  final repo = ref.watch(seriesMetadataRepositoryProvider);
  yield* repo.watchSeriesMetadata(seriesId);
}

@riverpod
Stream<List<SeriesModel>> onDeck(Ref ref) async* {
  final repo = ref.watch(seriesRepositoryProvider);
  yield* repo.watchOnDeck();
}

@riverpod
Stream<List<SeriesModel>> recentlyUpdated(Ref ref) async* {
  final repo = ref.watch(seriesRepositoryProvider);
  yield* repo.watchRecentlyUpdated();
}

@riverpod
Stream<List<SeriesModel>> recentlyAdded(Ref ref) async* {
  final repo = ref.watch(seriesRepositoryProvider);
  yield* repo.watchRecentlyAdded();
}
