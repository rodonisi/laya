import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/riverpod/providers/client.dart';
import 'package:fluvita/riverpod/repository/database.dart';
import 'package:fluvita/sync/want_to_read_sync_operations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'want_to_read_repository.g.dart';

@riverpod
WantToReadRepository wantToReadRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final restClient = ref.watch(restClientProvider);
  final client = WantToReadSyncOperations(client: restClient);
  return WantToReadRepository(db, client);
}

class WantToReadRepository {
  final AppDatabase _db;
  final WantToReadSyncOperations _client;

  WantToReadRepository(this._db, this._client);

  /// Watch whether [seriesId] is in want-to-read
  Stream<bool> watchWantToRead(int seriesId) {
    return _db.seriesDao.watchWantToRead(seriesId);
  }

  /// Watch all series in want-to-read
  Stream<List<SeriesModel>> watchWantToReadList() {
    return _db.seriesDao.watchWantToReadList().map(
      (list) => list.map(SeriesModel.fromDatabaseModel).toList(),
    );
  }

  /// Add [seriesId] to want-to-read
  Future<void> add(int seriesId) async {
    await _db.seriesDao.upsertWantToRead(
      WantToReadCompanion(
        seriesId: Value(seriesId),
        isWantToRead: const Value(true),
        dirty: const Value(true),
      ),
    );
  }

  /// Remove [seriesId] from want-to-read
  Future<void> remove(int seriesId) async {
    await _db.seriesDao.removeWantToRead(seriesId: seriesId);
  }

  /// Merge local want-to-read changes with the server.
  Future<void> mergeWantToRead() async {
    final dirty = await _db.seriesDao.getDirtyWantToRead();

    final toAdd = dirty
        .where((data) => data.isWantToRead)
        .map((data) => data.seriesId)
        .toList();
    final toRemove = dirty
        .where((data) => !data.isWantToRead)
        .map((data) => data.seriesId)
        .toList();

    await Future.wait([_client.add(toAdd), _client.remove(toRemove)]);

    final series = await _client.getWantToReadList();

    await _db.seriesDao.upsertWantToReadFromSeriesBatch(series);
  }
}
