import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/volumes.dart';
import 'package:stream_transform/stream_transform.dart';

part 'volumes_dao.g.dart';

@DriftAccessor(tables: [Volumes, VolumeCovers])
class VolumesDao extends DatabaseAccessor<AppDatabase> with _$VolumesDaoMixin {
  VolumesDao(super.attachedDatabase);

  Stream<Volume> watchVolume(int volumeId) {
    return (select(
          volumes,
        )..where((row) => row.id.equals(volumeId)))
        .watchSingleOrNull()
        .whereNotNull();
  }

  Stream<VolumeCover> watchVolumeCover({required int volumeId}) {
    return (select(
          volumeCovers,
        )..where((row) => row.volumeId.equals(volumeId)))
        .watchSingleOrNull()
        .whereNotNull();
  }

  Future<void> upsertVolume(VolumesCompanion volume) async {
    await into(volumes).insertOnConflictUpdate(volume);
  }

  Future<void> upsertVolumeCover(VolumeCoversCompanion cover) async {
    await into(volumeCovers).insertOnConflictUpdate(cover);
  }
}
