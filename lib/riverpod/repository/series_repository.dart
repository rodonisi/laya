import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/dao/series_metadata_dao.dart';
import 'package:fluvita/models/image_model.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/riverpod/providers/client.dart';
import 'package:fluvita/riverpod/providers/settings/settings.dart';
import 'package:fluvita/riverpod/repository/database.dart';
import 'package:fluvita/sync/series_sync_operations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'series_repository.g.dart';

@riverpod
SeriesRepository seriesRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final restClient = ref.watch(restClientProvider);
  final apiKey = ref.watch(apiKeyProvider);
  final client = SeriesSyncOperations(
    client: restClient,
    apiKey: apiKey ?? '',
  );
  return SeriesRepository(db, client);
}

class SeriesRepository {
  final AppDatabase _db;
  final SeriesSyncOperations _client;

  const SeriesRepository(this._db, this._client);

  /// Watch series [seriesId]
  Stream<SeriesModel> watchSeries(int seriesId) {
    return _db.seriesDao
        .watchSeries(seriesId)
        .map(SeriesModel.fromDatabaseModel);
  }

  /// Watch [SeriesMetadataModel] for series [seriesId]
  Stream<SeriesMetadataModel> watchSeriesMetadata(int seriesId) {
    return _db.seriesMetadataDao
        .watchSeriesMetadata(seriesId)
        .map(SeriesMetadataModel.fromDatabaseModel);
  }

  /// Watch total number of pages read for series [seriesId]
  Stream<int> watchPagesRead({required int seriesId}) {
    return _db.seriesDao.watchPagesRead(seriesId: seriesId).map((n) => n ?? 0);
  }

  /// Watch series cover for series [seriesId]
  Stream<ImageModel> watchSeriesCover(int seriesId) {
    return _db.seriesDao
        .watchSeriesCover(seriesId: seriesId)
        .map((cover) => ImageModel(data: cover.image));
  }

  /// Watch [SeriesDetailModel] for series [seriesId]
  Stream<SeriesDetailModel> watchSeriesDetails(int seriesId) {
    return _db.seriesDao
        .watchSeriesDetail(seriesId)
        .map(SeriesDetailModel.fromDatabaseModel);
  }

  /// Watch the list of all series, optionally filterying by [libraryId]
  Stream<List<SeriesModel>> watchAllSeries({int? libraryId}) {
    return _db.seriesDao
        .allSeries(libraryId: libraryId)
        .watch()
        .distinct()
        .map(
          (list) => list.map(SeriesModel.fromDatabaseModel).toList(),
        );
  }

  /// Watch series marked as on deck
  Stream<List<SeriesModel>> watchOnDeck() {
    return _db.seriesDao.watchOnDeck().map(
      (list) => list.map(SeriesModel.fromDatabaseModel).toList(),
    );
  }

  /// Watch series marked as recently added
  Stream<List<SeriesModel>> watchRecentlyAdded() {
    return _db.seriesDao.watchRecentlyAdded().map(
      (list) => list.map(SeriesModel.fromDatabaseModel).toList(),
    );
  }

  /// Watch series marked as recently updated
  Stream<List<SeriesModel>> watchRecentlyUpdated() {
    return _db.seriesDao.watchRecentlyUpdated().map(
      (list) => list.map(SeriesModel.fromDatabaseModel).toList(),
    );
  }

  /// Refresh all series, optionally filtering by [libraryId]
  Future<void> refreshAllSeries({int? libraryId}) async {
    final series = await _client.getAllSeries(libraryId: libraryId);
    await _db.seriesDao.upsertSeriesBatch(series);
  }

  /// Refresh metadata for all series
  Future<void> refreshAllSeriesMetadata() async {
    final rows = await _db.seriesDao.allSeries().get();
    final series = rows.map((s) => s.id).toList();

    final metadata = <SeriesMetadataCompanions>[];
    for (final id in series) {
      metadata.add(await _client.getSeriesMetadata(id));
    }

    await _db.seriesMetadataDao.upsertMetadataBatch(metadata);
  }

  /// Refresh series details (chapters, volumes, etc) for all series
  Future<void> refreshAllSeriesDetails() async {
    final rows = await _db.seriesDao.allSeries().get();
    final series = rows.map((s) => s.id).toList();

    for (final id in series) {
      await refreshSeriesDetails(id);
    }
  }

  /// Refresh series on deck
  Future<void> refreshOnDeck() async {
    final series = await _client.getOnDeck();
    await _db.transaction(() async {
      await _db.seriesDao.clearOnDeck();
      await _db.seriesDao.upsertSeriesBatch(series);
    });
  }

  /// Refresh recently added series
  Future<void> refreshRecentlyAdded() async {
    final series = await _client.getRecentlyAdded();
    await _db.transaction(() async {
      await _db.seriesDao.clearIsRecentlyAdded();
      await _db.seriesDao.upsertSeriesBatch(series);
    });
  }

  /// Refresh recently updated series
  Future<void> refreshRecentlyUpdated() async {
    final series = await _client.getRecentlyUpdated();
    await _db.transaction(() async {
      await _db.seriesDao.clearIsRecentlyUpdated();
      await _db.seriesDao.upsertRecentlyUpdated(series);
    });
  }

  /// Refresh series details for series [seriesId]
  Future<void> refreshSeriesDetails(int seriesId) async {
    final details = await _client.getSeriesDetail(seriesId);
    await _db.seriesDao.upsertSeriesDetail(
      details,
    );
  }

  /// Fetch all missing series covers
  Future<void> fetchMissingCovers() async {
    final missingIds = await _db.seriesDao.getMissingCovers();
    for (final id in missingIds) {
      final seriesCover = await _client.getSeriesCover(id);
      await _db.seriesDao.upsertSeriesCover(seriesCover);
    }
  }
}
