import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';

class VolumeSyncOperations {
  final Openapi _client;
  final String _apiKey;

  const VolumeSyncOperations({
    required Openapi client,
    required String apiKey,
  }) : _client = client,
       _apiKey = apiKey;

  /// Get cover for volume [volumeId]
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
