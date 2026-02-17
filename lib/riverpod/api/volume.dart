import 'package:fluvita/models/image_model.dart';
import 'package:fluvita/models/volume_model.dart';
import 'package:fluvita/riverpod/repository/volumes_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'volume.g.dart';

@riverpod
Stream<VolumeModel> volume(Ref ref, {required int volumeId}) async* {
  final repo = ref.watch(volumesRepositoryProvider);
  yield* repo.watchVolume(volumeId);
}

@riverpod
Stream<ImageModel> volumeCover(Ref ref, {required int volumeId}) async* {
  final repo = ref.watch(volumesRepositoryProvider);
  yield* repo.watchVolumeCover(volumeId);
}
