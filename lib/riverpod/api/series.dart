import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'series.g.dart';

@riverpod
Future<SeriesModel> series(Ref ref, {required int seriesId}) async {
  final client = ref.watch(restClientProvider);
  final res = await client.apiSeriesSeriesIdGet(seriesId: seriesId);

  if (!res.isSuccessful || res.body == null) {
    throw Exception('Failed to load series: ${res.error}');
  }

  return SeriesModel.fromSeriesDto(res.body!);
}

@riverpod
Future<List<SeriesModel>> allSeries(Ref ref, {int? libraryId}) async {
  final client = ref.watch(restClientProvider);
  final res = await client.apiSeriesV2Post(
    body: FilterV2Dto(
      id: 0,
      combination: FilterV2DtoCombination.value_0.value,
      sortOptions: SortOptions(
        sortField: SortOptionsSortField.value_1.value,
        isAscending: false,
      ),
      limitTo: 0,
      statements: [
        if (libraryId != null)
          FilterStatementDto(
            comparison: FilterStatementDtoComparison.value_0.value,
            field: FilterStatementDtoField.value_19.value,
            value: libraryId.toString(),
          ),
      ],
    ),
  );

  if (!res.isSuccessful || res.body == null) {
    throw Exception('Failed to load all series: ${res.error}');
  }

  return res.body!.map(SeriesModel.fromSeriesDto).toList();
}

@riverpod
Future<SeriesDetailModel> seriesDetail(Ref ref, {required int seriesId}) async {
  final client = ref.watch(restClientProvider);
  final res = await client.apiSeriesSeriesDetailGet(seriesId: seriesId);

  if (!res.isSuccessful || res.body == null) {
    throw Exception('Failed to load series detail: ${res.error}');
  }

  return SeriesDetailModel.fromSeriesDetailDto(res.body!);
}

@riverpod
Future<SeriesMetadataModel> seriesMetadata(
  Ref ref, {
  required int seriesId,
}) async {
  final client = ref.watch(restClientProvider);
  final res = await client.apiSeriesMetadataGet(seriesId: seriesId);

  if (!res.isSuccessful || res.body == null) {
    throw Exception('Failed to load series metadata: ${res.error}');
  }

  return SeriesMetadataModel.fromSeriesMetadataDto(res.body!);
}

@riverpod
Future<List<SeriesModel>> onDeck(Ref ref) async {
  final client = ref.watch(restClientProvider);
  final res = await client.apiSeriesOnDeckPost();

  if (!res.isSuccessful || res.body == null) {
    throw Exception('Failed to load on deck: ${res.error}');
  }

  return res.body!.map(SeriesModel.fromSeriesDto).toList();
}

@riverpod
Future<List<SeriesModel>> recentlyUpdated(Ref ref) async {
  final client = ref.watch(restClientProvider);
  final res = await client.apiSeriesRecentlyUpdatedSeriesPost();

  if (!res.isSuccessful || res.body == null) {
    throw Exception('Failed to load recently updated: ${res.error}');
  }

  final seriesModels = res.body!
      .map(
        (dto) async =>
            await ref.watch(seriesProvider(seriesId: dto.seriesId!).future),
      )
      .toList();
  return await Future.wait(seriesModels);
}

@riverpod
Future<List<SeriesModel>> recentlyAdded(Ref ref) async {
  final client = ref.watch(restClientProvider);
  final res = await client.apiSeriesRecentlyAddedV2Post(
    body: FilterV2Dto(
      id: 0,
      combination: FilterV2DtoCombination.value_0.value,
      sortOptions: SortOptions(
        sortField: SortOptionsSortField.value_1.value,
        isAscending: false,
      ),
      limitTo: 0,
      statements: [],
    ),
  );

  if (!res.isSuccessful || res.body == null) {
    throw Exception('Failed to load recently added: ${res.error}');
  }

  return res.body!.map(SeriesModel.fromSeriesDto).toList();
}
