import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/series.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/repository/database.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'series_repository.g.dart';

@riverpod
SeriesRepository seriesRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final client = SeriesRemoteOperations(ref.watch(restClientProvider));
  return SeriesRepository(db, client);
}

class SeriesRepository {
  final AppDatabase _db;
  final SeriesRemoteOperations _client;

  SeriesRepository(this._db, this._client) {
    refreshAllSeries();
  }

  Stream<SeriesModel> watchSeries(int seriesId) {
    refreshSeries(seriesId);
    return _db.seriesDao
        .watchSeries(seriesId)
        .map(SeriesModel.fromDatabaseModel);
  }

  Stream<List<SeriesModel>> watchAllSeries({int? libraryId}) {
    refreshAllSeries(libraryId: libraryId);
    return _db.seriesDao
        .watchAllSeries(libraryId: libraryId)
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

  Stream<List<SeriesModel>> watchRecentlyUpdated() {
    refreshRecentlyUpdated();
    return _db.seriesDao.watchRecentlyUpdated().map(
      (list) => list.map(SeriesModel.fromDatabaseModel).toList(),
    );
  }

  Stream<List<SeriesModel>> watchRecentlyAdded() {
    refreshRecentlyAdded();
    return _db.seriesDao.watchRecentlyAdded().map(
      (list) => list.map(SeriesModel.fromDatabaseModel).toList(),
    );
  }

  Future<void> refreshSeries(int seriesId) async {
    try {
      final series = await _client.getSeries(seriesId);
      await _db.seriesDao.upsertSeries(series);
    } catch (e) {
      log.e(e);
    }
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

  Future<void> refreshRecentlyUpdated() async {
    try {
      final series = await _client.getRecentlyUpdated();
      await _db.seriesDao.upsertRecentlyUpdated(series);
    } catch (e) {
      log.e(e);
    }
  }

  Future<void> refreshRecentlyAdded() async {
    try {
      final series = await _client.getRecentlyAdded();
      await _db.seriesDao.upsertSeriesBatch(series);
    } catch (e) {
      log.e(e);
    }
  }
}

class SeriesRemoteOperations {
  final Openapi _client;

  const SeriesRemoteOperations(this._client);

  Future<SeriesCompanion> getSeries(int seriesId) async {
    final res = await _client.apiSeriesSeriesIdGet(seriesId: seriesId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load series: ${res.error}');
    }

    return _mapSeriesCompanion(res.body!);
  }

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

    return res.body!.map(_mapSeriesCompanion);
  }

  Future<Iterable<SeriesCompanion>> getOnDeck() async {
    final res = await _client.apiSeriesOnDeckPost();

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load on deck: ${res.error}');
    }

    return res.body!.map(
      (dto) => _mapSeriesCompanion(dto).copyWith(isOnDeck: const Value(true)),
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
          _mapSeriesCompanion(dto).copyWith(isRecentlyAdded: const Value(true)),
    );
  }

  SeriesCompanion _mapSeriesCompanion(SeriesDto dto) {
    return SeriesCompanion(
      id: Value(dto.id!),
      name: Value(dto.name!),
      originalName: Value(dto.originalName),
      localizedName: Value(dto.localizedName),
      sortName: Value(dto.sortName!),
      libraryId: Value(dto.libraryId!),
      format: Value(Format.fromDtoFormat(dto.format!)),
      pages: Value(dto.pages!),
      wordCount: Value(dto.wordCount ?? 0),
      avgHoursToRead: Value(dto.avgHoursToRead),
      primaryColor: Value(dto.primaryColor),
      secondaryColor: Value(dto.secondaryColor),
      pagesRead: Value(dto.pagesRead!),
      created: Value(dto.created!),
      lastModified: Value(DateTime.now()),
      lastChapterAdded: Value(dto.lastChapterAddedUtc),
      lastRead: Value(dto.latestReadDate),
    );
  }
}
