import 'package:fluvita/models/volume_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'volume.g.dart';

@riverpod
Future<VolumeModel> volume(Ref ref, {required int volumeId}) async {
  final client = ref.watch(restClientProvider);
  final res = await client.apiVolumeGet(volumeId: volumeId);

  if (!res.isSuccessful || res.body == null) {
    throw Exception('Failed to load volume: ${res.error}');
  }

  return VolumeModel.fromVolumeDto(res.body!);
}
