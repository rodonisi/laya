import 'package:fluvita/models/image_model.dart';
import 'package:fluvita/models/volume_model.dart';
import 'package:fluvita/riverpod/repository/volumes_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'volume.g.dart';

@riverpod
Stream<VolumeModel> volume(Ref ref, {required int volumeId}) async* {
  final repo = ref.watch(volumesRepositoryProvider);
  yield* repo.watchVolume(volumeId).distinct();
}

@riverpod
Stream<double> volumeProgress(Ref ref, {required int volumeId}) async* {
  final repo = ref.watch(volumesRepositoryProvider);
  final volume = repo.watchVolume(volumeId);
  final pagesRead = repo.watchPagesRead(volumeId: volumeId);

  yield* Rx.combineLatest2(volume, pagesRead, (v, n) => n / v.pages).distinct();
}

@riverpod
Stream<ImageModel> volumeCover(Ref ref, {required int volumeId}) async* {
  final repo = ref.watch(volumesRepositoryProvider);
  yield* repo.watchVolumeCover(volumeId).distinct();
}
