import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/mapping/dto/series_dto_mappings.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/repository/database.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:fluvita/utils/try_refresh.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'want_to_read_repository.g.dart';

@riverpod
WantToReadRepository wantToReadRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final restClient = ref.watch(restClientProvider);
  final client = WantToReadRemoteOperations(client: restClient);
  return WantToReadRepository(db, client);
}

class WantToReadRepository {
  final AppDatabase _db;
  final WantToReadRemoteOperations _client;

  WantToReadRepository(this._db, this._client);

  Stream<bool> watchWantToRead(int seriesId) {
    refreshWantToRead(seriesId);
    return _db.seriesDao.watchWantToRead(seriesId);
  }

  Stream<List<SeriesModel>> watchWantToReadList() {
    refreshWantToReadList();
    return _db.seriesDao.watchWantToReadList().map(
      (list) => list.map(SeriesModel.fromDatabaseModel).toList(),
    );
  }

  Future<void> add(int seriesId) async {
    // Optimistic local write first so the UI reacts instantly.
    await _db.seriesDao.upsertWantToRead(
      WantToReadCompanion(seriesId: Value(seriesId), dirty: const Value(true)),
    );
  }

  Future<void> remove(int seriesId) async {
    await _db.seriesDao.removeWantToRead(seriesId: seriesId);
  }

  Future<void> refreshWantToRead(int seriesId) async {
    await tryRefresh(() async {
      final isWantToRead = await _client.getWantToRead(seriesId);
      if (isWantToRead) {
        await _db.seriesDao.upsertWantToRead(
          WantToReadCompanion(seriesId: Value(seriesId)),
        );
      } else {
        await _db.seriesDao.removeWantToRead(seriesId: seriesId);
      }
    });
  }

  Future<void> refreshWantToReadList() async {
    try {
      final series = await _client.getWantToReadList();
      final wantToReads = series.map(
        (s) => WantToReadCompanion(
          seriesId: s.id,
        ),
      );
      await _db.transaction(() async {
        await _db.seriesDao.clearWantToRead();
        await _db.seriesDao.upsertSeriesBatch(series);
        await _db.seriesDao.upsertWantToReadBatch(wantToReads);
      });
    } catch (e) {
      log.e(e);
    }
  }
}

class WantToReadRemoteOperations {
  final Openapi _client;

  const WantToReadRemoteOperations({required Openapi client})
    : _client = client;

  Future<bool> getWantToRead(int seriesId) async {
    final res = await _client.apiWantToReadGet(seriesId: seriesId);
    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load want-to-read status: ${res.error}');
    }
    return res.body!;
  }

  Future<Iterable<SeriesCompanion>> getWantToReadList() async {
    final res = await _client.apiWantToReadV2Post(
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
            value: 'true',
          ),
        ],
      ),
    );
    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load want-to-read list: ${res.error}');
    }
    return res.body!.map(
      (dto) => dto.toSeriesCompanion(),
    );
  }

  Future<void> add(List<int> seriesIds) async {
    final res = await _client.apiWantToReadAddSeriesPost(
      body: UpdateWantToReadDto(seriesIds: seriesIds),
    );
    if (!res.isSuccessful) {
      throw Exception('Failed to add to want-to-read: ${res.error}');
    }
  }

  Future<void> remove(List<int> seriesIds) async {
    final res = await _client.apiWantToReadRemoveSeriesPost(
      body: UpdateWantToReadDto(seriesIds: seriesIds),
    );
    if (!res.isSuccessful) {
      throw Exception('Failed to remove from want-to-read: ${res.error}');
    }
  }
}
