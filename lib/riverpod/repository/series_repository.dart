import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/dao/series_dao.dart';
import 'package:fluvita/mapping/dto/chapter_dto_mappings.dart';
import 'package:fluvita/mapping/dto/series_dto_mappings.dart';
import 'package:fluvita/mapping/dto/volume_dto_mappings.dart';
import 'package:fluvita/models/image_model.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/repository/database.dart';
import 'package:fluvita/riverpod/settings.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:fluvita/utils/try_refresh.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'series_repository.g.dart';

@riverpod
SeriesRepository seriesRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final restClient = ref.watch(restClientProvider);
  final apiKey = ref.watch(apiKeyProvider);
  final client = SeriesRemoteOperations(
    client: restClient,
    apiKey: apiKey ?? '',
  );
  return SeriesRepository(db, client);
}

class SeriesRepository {
  final AppDatabase _db;
  final SeriesRemoteOperations _client;

  SeriesRepository(this._db, this._client) {
    refreshAllSeries();
  }

  Future<void> refreshAllSeries({int? libraryId}) async {
    try {
      final series = await _client.getAllSeries(libraryId: libraryId);
      await _db.seriesDao.upsertSeriesBatch(series);
    } catch (e) {
      log.e(e);
    }
  }

  Future<void> refreshedOnDeck() async {
    try {
      log.d('refreshing on deck');
      final series = await _client.getOnDeck();
      await _db.seriesDao.upsertSeriesBatch(series);
    } catch (e) {
      log.e(e);
    }
  }

  Future<void> refreshRecentlyAdded() async {
    await tryRefresh(() async {
      final series = await _client.getRecentlyAdded();
      await _db.seriesDao.upsertSeriesBatch(series);
    });
  }

  Future<void> refreshRecentlyUpdated() async {
    try {
      final series = await _client.getRecentlyUpdated();
      await _db.seriesDao.upsertRecentlyUpdated(series);
    } catch (e) {
      log.e(e);
    }
  }

  Future<void> refreshSeries(int seriesId) async {
    try {
      final series = await _client.getSeries(seriesId);
      await _db.seriesDao.upsertSeries(series);
    } catch (e) {
      log.e(e);
    }
  }

  Future<void> refreshSeriesDetails(int seriesId) async {
    tryRefresh(() async {
      final details = await _client.getSeriesDetail(seriesId);
      await _db.seriesDao.upsertSeriesDetail(
        seriesId: seriesId,
        entries: details,
      );
    });
  }

  Future<void> refreshSeriesCover(int seriesId) async {
    try {
      final seriesCover = await _client.getSeriesCover(seriesId);
      await _db.seriesDao.upsertSeriesCover(seriesCover);
    } catch (e) {
      log.e(e);
    }
  }

  Stream<List<SeriesModel>> watchAllSeries({int? libraryId}) {
    refreshAllSeries(libraryId: libraryId);
    return _db.seriesDao
        .allSeries(libraryId: libraryId)
        .watch()
        .distinct()
        .map(
          (list) => list.map(SeriesModel.fromDatabaseModel).toList(),
        );
  }

  Stream<List<SeriesModel>> watchOnDeck() {
    refreshedOnDeck();
    return _db.seriesDao.watchOnDeck().map(
      (list) => list.map(SeriesModel.fromDatabaseModel).toList(),
    );
  }

  Stream<List<SeriesModel>> watchRecentlyAdded() {
    refreshRecentlyAdded();
    return _db.seriesDao.watchRecentlyAdded().map(
      (list) => list.map(SeriesModel.fromDatabaseModel).toList(),
    );
  }

  Stream<List<SeriesModel>> watchRecentlyUpdated() {
    refreshRecentlyUpdated();
    return _db.seriesDao.watchRecentlyUpdated().map(
      (list) => list.map(SeriesModel.fromDatabaseModel).toList(),
    );
  }

  Stream<SeriesModel> watchSeries(int seriesId) {
    refreshSeries(seriesId);
    return _db.seriesDao
        .watchSeries(seriesId)
        .map(SeriesModel.fromDatabaseModel);
  }

  Stream<int> watchPagesRead({required int seriesId}) {
    return _db.seriesDao.watchPagesRead(seriesId: seriesId).map((n) => n ?? 0);
  }

  Stream<ImageModel> watchSeriesCover(int seriesId) {
    refreshSeriesCover(seriesId);
    return _db.seriesDao
        .watchSeriesCover(seriesId: seriesId)
        .map((cover) => ImageModel(data: cover.image));
  }

  Stream<SeriesDetailModel> watchSeriesDetails(int seriesId) {
    refreshSeriesDetails(seriesId);
    return _db.seriesDao
        .watchSeriesDetail(seriesId)
        .map(SeriesDetailModel.fromDatabaseModel);
  }
}

class SeriesRemoteOperations {
  final Openapi _client;
  final String _apiKey;

  const SeriesRemoteOperations({
    required Openapi client,
    required String apiKey,
  }) : _client = client,
       _apiKey = apiKey;

  Future<Iterable<SeriesCompanion>> getAllSeries({int? libraryId}) async {
    final res = await _client.apiSeriesV2Post(
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
      throw Exception('Failed to load series: ${res.error}');
    }

    return res.body!.map((dto) => dto.toSeriesCompanion());
  }

  Future<Iterable<SeriesCompanion>> getOnDeck() async {
    final res = await _client.apiSeriesOnDeckPost();

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load on deck: ${res.error}');
    }

    return res.body!.map(
      (dto) => dto.toSeriesCompanion().copyWith(isOnDeck: const Value(true)),
    );
  }

  Future<Iterable<SeriesCompanion>> getRecentlyAdded() async {
    final res = await _client.apiSeriesRecentlyAddedV2Post(
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

    return res.body!.map(
      (dto) =>
          dto.toSeriesCompanion().copyWith(isRecentlyAdded: const Value(true)),
    );
  }

  Future<Iterable<SeriesCompanion>> getRecentlyUpdated() async {
    final res = await _client.apiSeriesRecentlyUpdatedSeriesPost();

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load recently updated: ${res.error}');
    }

    return Future.wait(
      res.body!.map(
        (entry) async {
          final series = await getSeries(entry.seriesId!);
          return series.copyWith(isRecentlyUpdated: const Value(true));
        },
      ),
    );
  }

  Future<SeriesCompanion> getSeries(int seriesId) async {
    final res = await _client.apiSeriesSeriesIdGet(seriesId: seriesId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load series: ${res.error}');
    }

    return res.body!.toSeriesCompanion();
  }

  Future<SeriesCoversCompanion> getSeriesCover(int seriesId) async {
    final res = await _client.apiImageSeriesCoverGet(
      seriesId: seriesId,
      apiKey: _apiKey,
    );

    if (!res.isSuccessful) {
      throw Exception('Failed to load series cover: ${res.error}');
    }

    return SeriesCoversCompanion(
      seriesId: Value(seriesId),
      image: Value(res.bodyBytes),
    );
  }

  Future<SeriesDetailCompanions> getSeriesDetail(
    int seriesId,
  ) async {
    final res = await _client.apiSeriesSeriesDetailGet(seriesId: seriesId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load series detail: ${res.error}');
    }

    final dto = res.body!;

    final storyline = (dto.specials ?? []).map(
      (c) => c.toChapterCompanion().copyWith(
        seriesId: Value(seriesId),
        isStoryline: const Value(true),
      ),
    );
    final specials = (dto.specials ?? []).map(
      (c) => c.toChapterCompanion().copyWith(
        seriesId: Value(seriesId),
        isSpecial: const Value(true),
      ),
    );
    final chapters = (dto.chapters ?? []).map(
      (c) => c.toChapterCompanion().copyWith(
        seriesId: Value(seriesId),
      ),
    );
    final volumes = (dto.volumes ?? []).map(
      (v) => v.toVolumeCompanion(),
    );

    final allChapters = <ChapterDto>{
      ...dto.chapters ?? [],
      ...dto.specials ?? [],
      ...dto.storylineChapters ?? [],
      ...dto.volumes?.map((v) => v.chapters).expand((l) => l ?? []) ?? [],
    };

    final progress = allChapters.map(
      (c) => c.toPartialReadingProgressCompanion(),
    );

    return SeriesDetailCompanions(
      storyline: storyline,
      specials: specials,
      chapters: chapters,
      volumes: volumes,
      progress: progress,
    );
  }
}
