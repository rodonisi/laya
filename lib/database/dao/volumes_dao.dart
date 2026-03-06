import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/chapters.dart';
import 'package:fluvita/database/tables/progress.dart';
import 'package:fluvita/database/tables/volumes.dart';
import 'package:fluvita/utils/logging.dart';

part 'volumes_dao.g.dart';

@DriftAccessor(tables: [Volumes, VolumeCovers, Chapters, ReadingProgress])
class VolumesDao extends DatabaseAccessor<AppDatabase> with _$VolumesDaoMixin {
  VolumesDao(super.attachedDatabase);

  /// Get a [SingleSelectable] for volume [volumeId]
  SingleSelectable<VolumeWithRelations> volume(int volumeId) {
    return managers.volumes
        .withReferences(
          (prefetch) => prefetch(chaptersRefs: true),
        )
        .filter((f) => f.id(volumeId))
        .map((result) {
          final (vol, refs) = result;
          return VolumeWithRelations(
            volume: vol,
            chapters: refs.chaptersRefs.prefetchedData ?? [],
          );
        });
  }

  /// Watch pages read for volume [volumeId]
  Stream<int?> watchPagesRead({required int volumeId}) {
    final pagesReadSum = readingProgress.pagesRead.sum();

    final query = selectOnly(readingProgress)
      ..addColumns([pagesReadSum])
      ..where(readingProgress.volumeId.equals(volumeId))
      ..groupBy([readingProgress.volumeId]);

    return query.watchSingleOrNull().map((row) => row?.read(pagesReadSum));
  }

  /// Watch cover for volume [volumeId]. If no cover is present, returns null.
  Stream<VolumeCover?> watchVolumeCover({required int volumeId}) {
    return (select(
      volumeCovers,
    )..where((row) => row.volumeId.equals(volumeId))).watchSingleOrNull();
  }

  /// Get all volume ids missing a cover
  Future<List<int>> getMissingCovers() async {
    final query = select(volumes).join([
      leftOuterJoin(volumeCovers, volumeCovers.volumeId.equalsExp(volumes.id)),
    ]);

    query.where(volumeCovers.volumeId.isNull());

    return await query.map((row) => row.readTable(volumes).id).get();
  }

  /// Upsert a batch of [VolumeWithRelations], effectively upserting the volume,
  /// as well as all its chapters.
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

  /// Upsert a volume cover
  Future<void> upsertVolumeCover(VolumeCoversCompanion cover) async {
    await into(volumeCovers).insertOnConflictUpdate(cover);
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
