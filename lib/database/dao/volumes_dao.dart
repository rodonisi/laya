import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/chapters.dart';
import 'package:fluvita/database/tables/volumes.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:stream_transform/stream_transform.dart';

part 'volumes_dao.g.dart';

@DriftAccessor(tables: [Volumes, VolumeCovers, Chapters])
class VolumesDao extends DatabaseAccessor<AppDatabase> with _$VolumesDaoMixin {
  VolumesDao(super.attachedDatabase);

  Stream<VolumeWithRelations> watchVolume(int volumeId) {
    final volumeQuery = select(volumes)
      ..where((row) => row.id.equals(volumeId));

    final chaptersQuery = select(chapters)
      ..where((row) => row.volumeId.equals(volumeId))
      ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]);

    return volumeQuery.watchSingleOrNull().switchMap((volume) async* {
      if (volume == null) {
        return;
      }

      await for (final chaptersList in chaptersQuery.watch()) {
        yield VolumeWithRelations(
          volume: volume,
          chapters: chaptersList,
        );
      }
    });
  }

  Stream<VolumeCover> watchVolumeCover({required int volumeId}) {
    return (select(
          volumeCovers,
        )..where((row) => row.volumeId.equals(volumeId)))
        .watchSingleOrNull()
        .whereNotNull()
        .distinct();
  }

  Future<void> upsertVolume(VolumeWithChaptersCompanion entry) async {
    await transaction(() async {
      await into(volumes).insertOnConflictUpdate(entry.volume);
      db.chaptersDao.upsertChapterBatch(entry.chapters);
    });
  }

  Future<void> upsertVolumeBatch(
    Iterable<VolumeWithChaptersCompanion> entries,
  ) async {
    log.d('upserting volumes batch with ${entries.length} entries');
    await transaction(() async {
      await batch((batch) {
        batch.insertAllOnConflictUpdate(volumes, entries.map((e) => e.volume));
      });
      await db.chaptersDao.upsertChapterBatch(
        entries.map((e) => e.chapters).expand((l) => l),
      );
    });
  }

  Future<void> upsertVolumeCover(VolumeCoversCompanion cover) async {
    await into(volumeCovers).insertOnConflictUpdate(cover);
  }

  Future<void> clearSeriesVolumes({required int seriesId}) async {
    await (delete(volumes)..where((row) => row.seriesId.equals(seriesId))).go();
  }
}

class VolumeWithRelations {
  final Volume volume;
  final List<Chapter> chapters;

  const VolumeWithRelations({required this.volume, required this.chapters});
}

class VolumeWithChaptersCompanion {
  final VolumesCompanion volume;
  final Iterable<ChaptersCompanion> chapters;

  const VolumeWithChaptersCompanion({
    required this.volume,
    this.chapters = const [],
  });
}
