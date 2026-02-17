import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
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
    refreshVolume(volumeId);
    return _db.volumesDao
        .watchVolume(volumeId)
        .map(VolumeModel.fromDatabaseModel);
  }

  Stream<ImageModel> watchVolumeCover(int volumeId) {
    refreshVolumeCover(volumeId);
    return _db.volumesDao
        .watchVolumeCover(volumeId: volumeId)
        .map((cover) => ImageModel(data: cover.image));
  }

  Future<void> refreshVolume(int volumeId) async {
    try {
      final volume = await _client.getVolume(volumeId);
      await _db.volumesDao.upsertVolume(volume);
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

  Future<VolumesCompanion> getVolume(int volumeId) async {
    final res = await _client.apiVolumeGet(volumeId: volumeId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load volume: ${res.error}');
    }

    return _mapVolumeCompanion(res.body!);
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

  VolumesCompanion _mapVolumeCompanion(VolumeDto dto) {
    return VolumesCompanion(
      id: Value(dto.id!),
      seriesId: Value(dto.seriesId!),
      name: Value(dto.name),
      wordCount: Value(dto.wordCount!),
      pages: Value(dto.pages!),
      pagesRead: Value(dto.pagesRead!),
      avgHoursToRead: Value(dto.avgHoursToRead),
      primaryColor: Value(dto.primaryColor),
      secondaryColor: Value(dto.secondaryColor),
      created: Value(dto.createdUtc ?? DateTime.now()),
      lastModified: Value(DateTime.now()),
    );
  }
}
