import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/series.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'series_repository.g.dart';

/// Database provider
@riverpod
AppDatabase database(Ref ref) {
  return AppDatabase();
}

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

  Stream<List<SeriesModel>> watchOnDeck() {
    refreshedOnDeck();
    return _db.watchOnDeck().map(
      (list) => list.map(SeriesModel.fromDatabaseModel).toList(),
    );
  }

  Future<void> refreshAllSeries() async {
    try {
      final series = await _client.getAllSeries();
      await _db.upsertSeriesBatch(series);
    } catch (e) {
      log.e(e);
    }
  }

  Future<void> refreshedOnDeck() async {
    try {
      log.d('refreshing on deck');
      final series = await _client.getOnDeck();
      await _db.upsertSeriesBatch(series);
    } catch (e) {
      log.e(e);
    }
  }

  Future<void> refreshRecentlyUpdated() async {
    try {
      final ids = await _client.getRecentlyUpdated();
      await _db.upsertRecentlyUpdated(ids);
    } catch (e) {
      log.e(e);
    }
  }

  Future<void> refreshRecentlyAdded() async {
    try {
      final series = await _client.getRecentlyAdded();
      await _db.upsertSeriesBatch(series);
    } catch (e) {
      log.e(e);
    }
  }
}

class SeriesRemoteOperations {
  final Openapi _client;

  const SeriesRemoteOperations(this._client);

  Future<Iterable<SeriesCompanion>> getAllSeries() async {
    final res = await _client.apiSeriesV2Post(
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

  Future<Iterable<int>> getRecentlyUpdated() async {
    final res = await _client.apiSeriesRecentlyUpdatedSeriesPost();

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load recently updated: ${res.error}');
    }

    return res.body!.map((entry) => entry.seriesId!);
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
      coverImageUrl: Value(dto.coverImage),
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
