import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/repository/series_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'series.g.dart';

@riverpod
class Series extends _$Series {
  @override
  Future<SeriesModel> build({required int seriesId}) async {
    final client = ref.watch(restClientProvider);
    final res = await client.apiSeriesSeriesIdGet(seriesId: seriesId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load series: ${res.error}');
    }

    return SeriesModel.fromSeriesDto(res.body!);
  }
}

@riverpod
class AllSeries extends _$AllSeries {
  @override
  Future<List<SeriesModel>> build({int? libraryId}) async {
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
}

@riverpod
class SeriesDetail extends _$SeriesDetail {
  @override
  Future<SeriesDetailModel> build({required int seriesId}) async {
    final client = ref.watch(restClientProvider);
    final res = await client.apiSeriesSeriesDetailGet(seriesId: seriesId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load series detail: ${res.error}');
    }

    return SeriesDetailModel.fromSeriesDetailDto(res.body!);
  }
}

@riverpod
class SeriesMetadata extends _$SeriesMetadata {
  @override
  Future<SeriesMetadataModel> build({
    required int seriesId,
  }) async {
    final client = ref.watch(restClientProvider);
    final res = await client.apiSeriesMetadataGet(seriesId: seriesId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load series metadata: ${res.error}');
    }

    return SeriesMetadataModel.fromSeriesMetadataDto(res.body!);
  }
}

@riverpod
Stream<List<SeriesModel>> onDeck(Ref ref) async* {
  final repo = ref.watch(seriesRepositoryProvider);
  yield* repo.watchOnDeck();
}

@riverpod
class RecentlyUpdated extends _$RecentlyUpdated {
  @override
  Future<List<SeriesModel>> build() async {
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
}

@riverpod
class RecentlyAdded extends _$RecentlyAdded {
  @override
  Future<List<SeriesModel>> build() async {
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
}
