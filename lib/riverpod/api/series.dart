import 'package:fluvita/api/models/filter_statement_dto.dart';
import 'package:fluvita/api/models/filter_v2_dto.dart';
import 'package:fluvita/api/models/sort_options.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'series.g.dart';

@riverpod
Future<SeriesModel> series(Ref ref, {required int seriesId}) async {
  final client = ref.watch(restClientProvider).series;
  final res = await client.getApiSeriesSeriesId(seriesId: seriesId);

  return SeriesModel.fromSeriesDto(res);
}

@riverpod
Future<List<SeriesModel>> allSeries(Ref ref, {int? libraryId}) async {
  final client = ref.watch(restClientProvider).series;
  final res = await client.postApiSeriesV2(
    body: FilterV2Dto(
      id: 0,
      combination: .value0,
      sortOptions: SortOptions(sortField: .value1, isAscending: false),
      limitTo: 0,
      statements: [
        if (libraryId != null)
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
Future<SeriesMetadataModel> seriesMetadata(
  Ref ref, {
  required int seriesId,
}) async {
  final client = ref.watch(restClientProvider).series;
  final res = await client.getApiSeriesMetadata(seriesId: seriesId);

  return SeriesMetadataModel.fromSeriesMetadataDto(res);
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

  final seriesModels = res
      .map(
        (dto) async =>
            await ref.watch(seriesProvider(seriesId: dto.seriesId!).future),
      )
      .toList();
  return await Future.wait(seriesModels);
}

@riverpod
Future<List<SeriesModel>> recentlyAdded(Ref ref) async {
  final client = ref.watch(restClientProvider).series;
  final res = await client.postApiSeriesRecentlyAddedV2();

  return res.map(SeriesModel.fromSeriesDto).toList();
}

// @riverpod
// Future<List<SeriesModel>> allSeries(Ref ref) async {
//   final client = ref.watch(restClientProvider).series;
//   final res = await client.postApiSeriesAllV2();
//
//   return res.map(SeriesModel.fromSeriesDto).toList();
// }
