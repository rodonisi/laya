import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/dao/volumes_dao.dart';
import 'package:fluvita/mapping/dto/volume_dto_mappings.dart';
import 'package:fluvita/models/image_model.dart';
import 'package:fluvita/models/volume_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/repository/database.dart';
import 'package:fluvita/riverpod/settings.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'volumes_repository.g.dart';

@riverpod
VolumesRepository volumesRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final restClient = ref.watch(restClientProvider);
  final apiKey = ref.watch(apiKeyProvider);
  final client = VolumeRemoteOperations(
    client: restClient,
    apiKey: apiKey ?? '',
  );
  return VolumesRepository(db, client);
}

class VolumesRepository {
  final AppDatabase _db;
  final VolumeRemoteOperations _client;

  VolumesRepository(this._db, this._client);

  Stream<VolumeModel> watchVolume(int volumeId) {
    return _db.volumesDao
        .watchVolume(volumeId)
        .map(VolumeModel.fromDatabaseModel);
  }

  Stream<int> watchPagesRead({required int volumeId}) {
    return _db.volumesDao.watchPagesRead(volumeId: volumeId).map((n) => n ?? 0);
  }

  Stream<ImageModel> watchVolumeCover(int volumeId) {
    refreshVolumeCover(volumeId);
    return _db.volumesDao
        .watchVolumeCover(volumeId: volumeId)
        .map((cover) => ImageModel(data: cover.image));
  }

  Future<void> refreshVolume(int volumeId) async {
    try {
      final companions = await _client.getVolume(volumeId);
      await _db.volumesDao.upsertVolume(companions);
    } catch (e) {
      log.e(e);
    }
  }

  Future<void> refreshVolumeCover(int volumeId) async {
    try {
      final volumeCover = await _client.getVolumeCover(volumeId);
      await _db.volumesDao.upsertVolumeCover(volumeCover);
    } catch (e) {
      log.e(e);
    }
  }
}

class VolumeRemoteOperations {
  final Openapi _client;
  final String _apiKey;

  const VolumeRemoteOperations({
    required Openapi client,
    required String apiKey,
  }) : _client = client,
       _apiKey = apiKey;

  Future<VolumeWithChaptersCompanion> getVolume(int volumeId) async {
    final res = await _client.apiVolumeGet(volumeId: volumeId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load volume: ${res.error}');
    }

    return res.body!.toVolumeCompanion();
  }

  Future<VolumeCoversCompanion> getVolumeCover(int volumeId) async {
    final res = await _client.apiImageVolumeCoverGet(
      volumeId: volumeId,
      apiKey: _apiKey,
    );

    if (!res.isSuccessful) {
      throw Exception('Failed to load volume cover: ${res.error}');
    }

    return VolumeCoversCompanion(
      volumeId: Value(volumeId),
      image: Value(res.bodyBytes),
    );
  }
}
