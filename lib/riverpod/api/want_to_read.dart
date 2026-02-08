import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'want_to_read.g.dart';

@riverpod
class WantToRead extends _$WantToRead {
  @override
  Future<bool> build({required int seriesId}) async {
    final client = ref.watch(restClientProvider);
    final res = await client.apiWantToReadGet(seriesId: seriesId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load series metadata: ${res.error}');
    }

    return res.body!;
  }

  Future<void> add() async {
    final client = ref.read(restClientProvider);
    final res = await client.apiWantToReadAddSeriesPost(
      body: UpdateWantToReadDto(seriesIds: [seriesId]),
    );
    if (res.isSuccessful) state = const AsyncValue.data(true);
    ref.invalidateSelf();
  }

  Future<void> remove() async {
    final client = ref.read(restClientProvider);
    final res = await client.apiWantToReadRemoveSeriesPost(
      body: UpdateWantToReadDto(seriesIds: [seriesId]),
    );
    if (res.isSuccessful) state = const AsyncValue.data(false);
    ref.invalidateSelf();
  }
}

@riverpod
class WantToReadList extends _$WantToReadList {
  @override
  Future<List<SeriesModel>> build() async {
    final client = ref.watch(restClientProvider);
    final res = await client.apiWantToReadV2Post(
      body: FilterV2Dto(
        id: 0,
        limitTo: 0,
        combination: FilterV2DtoCombination.value_1.value,
        sortOptions: SortOptions(
          sortField: SortOptionsSortField.value_1.value,
          isAscending: true,
        ),
        statements: [
          FilterStatementDto(
            comparison: FilterStatementDtoComparison.value_0.value,
            field: FilterStatementDtoField.value_26.value,
            value: "true",
          ),
        ],
      ),
    );

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load series metadata: ${res.error}');
    }

    return res.body!.map(SeriesModel.fromSeriesDto).toList();
  }

  Future<void> add(List<int> seriesIds) async {
    final client = ref.read(restClientProvider);
    await client.apiWantToReadAddSeriesPost(
      body: UpdateWantToReadDto(seriesIds: seriesIds),
    );
    ref.invalidateSelf();
  }

  Future<void> remove(List<int> seriesIds) async {
    final client = ref.read(restClientProvider);
    await client.apiWantToReadRemoveSeriesPost(
      body: UpdateWantToReadDto(seriesIds: seriesIds),
    );
    ref.invalidateSelf();
  }
}
