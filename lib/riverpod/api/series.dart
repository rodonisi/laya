import 'package:laya/api/models/filter_statement_dto.dart';
import 'package:laya/api/models/filter_v2_dto.dart';
import 'package:laya/api/models/sort_options.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/riverpod/api/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'series.g.dart';

@riverpod
Future<SeriesModel> series(Ref ref, {required int seriesId}) async {
  final client = ref.watch(restClientProvider).series;
  final res = await client.getApiSeriesSeriesId(seriesId: seriesId);

  return SeriesModel.fromSeriesDto(res);
}

@riverpod
Future<List<SeriesModel>> allSeries(Ref ref, int libraryId) async {
  final client = ref.watch(restClientProvider).series;
  final res = await client.postApiSeriesV2(
    body: FilterV2Dto(
      id: 0,
      combination: .value0,
      sortOptions: SortOptions(sortField: .value1, isAscending: false),
      limitTo: 0,
      statements: [
        FilterStatementDto(
          comparison: .value0,
          field: .value19,
          value: libraryId.toString(),
        ),
      ],
    ),
  );

  return res.map(SeriesModel.fromSeriesDto).toList();
}

@riverpod
Future<SeriesDetailModel> seriesDetail(Ref ref, {required int seriesId}) async {
  final client = ref.watch(restClientProvider).series;
  final res = await client.getApiSeriesSeriesDetail(seriesId: seriesId);

  return SeriesDetailModel.fromSeriesDetailDto(res);
}

@riverpod
Future<List<SeriesModel>> onDeck(Ref ref) async {
  final client = ref.watch(restClientProvider).series;
  final res = await client.postApiSeriesOnDeck();
  return res.map(SeriesModel.fromSeriesDto).toList();
}

@riverpod
Future<List<SeriesModel>> recentlyUpdated(Ref ref) async {
  final client = ref.watch(restClientProvider).series;
  final res = await client.postApiSeriesRecentlyUpdatedSeries();
  return res.map(SeriesModel.fromRecentlyAddedItemDto).toList();
}

@riverpod
Future<List<SeriesModel>> recentlyAdded(Ref ref) async {
  final client = ref.watch(restClientProvider).series;
  final res = await client.postApiSeriesRecentlyAddedV2();
  return res.map(SeriesModel.fromSeriesDto).toList();
}
