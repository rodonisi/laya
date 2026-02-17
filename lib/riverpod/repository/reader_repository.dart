import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/models/chapter_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/repository/database.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reader_repository.g.dart';

@riverpod
ReaderRepository readerRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final restClient = ref.watch(restClientProvider);
  final client = ReaderRemoteOperations(client: restClient);
  return ReaderRepository(db, client);
}

class ReaderRepository {
  final AppDatabase _db;
  final ReaderRemoteOperations _client;

  ReaderRepository(this._db, this._client);

  Stream<ChapterModel> watchContinuePoint({required int seriesId}) {
    refreshContinuePoint(seriesId);
    return _db.readerDao
        .continuePoint(seriesId: seriesId)
        .map(ChapterModel.fromDatabaseModel);
  }

  Future<void> refreshContinuePoint(int seriesId) async {
    try {
      final continuePoint = await _client.getContinuePoint(seriesId);
      await _db.readerDao.upsertContinuePoint(continuePoint);
    } catch (e) {
      log.e(e);
    }
  }
}

class ReaderRemoteOperations {
  final Openapi _client;

  const ReaderRemoteOperations({
    required Openapi client,
  }) : _client = client;

  Future<ContinuePointsCompanion> getContinuePoint(int seriesId) async {
    final res = await _client.apiReaderContinuePointGet(seriesId: seriesId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load continue point: ${res.error}');
    }

    final chapterDto = res.body!;
    return ContinuePointsCompanion(
      seriesId: Value(seriesId),
      chapterId: Value(chapterDto.id!),
    );
  }
}
