import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/dao/volumes_dao.dart';
import 'package:fluvita/database/tables/series.dart';
import 'package:fluvita/database/tables/volumes.dart';
import 'package:fluvita/database/tables/chapters.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:rxdart/rxdart.dart';

part 'series_dao.g.dart';

@DriftAccessor(tables: [Series, SeriesCovers, Volumes, Chapters])
class SeriesDao extends DatabaseAccessor<AppDatabase> with _$SeriesDaoMixin {
  SeriesDao(super.attachedDatabase);

  Stream<SeriesData> watchSeries(int seriesId) {
    return (select(
      series,
    )..where((row) => row.id.equals(seriesId))).watchSingle();
  }

  Stream<List<SeriesData>> watchAllSeries({int? libraryId}) {
    final query = select(series);
    if (libraryId != null) {
      return (query..where((row) => row.libraryId.equals(libraryId))).watch();
    }

    return query.watch();
  }

  Stream<List<SeriesData>> watchOnDeck() {
    return (select(series)
          ..where((row) => row.isOnDeck)
          ..orderBy([(t) => OrderingTerm.desc(t.lastRead)]))
        .watch();
  }

  Stream<List<SeriesData>> watchRecentlyUpdated() {
    return (select(series)
          ..where((row) => row.isRecentlyUpdated)
          ..orderBy([(t) => OrderingTerm.desc(t.lastChapterAdded)]))
        .watch();
  }

  Stream<List<SeriesData>> watchRecentlyAdded() {
    return (select(series)
          ..where((row) => row.isRecentlyAdded)
          ..orderBy([(t) => OrderingTerm.desc(t.created)]))
        .watch();
  }

  Stream<SeriesCover> watchSeriesCover({required int seriesId}) {
    return (select(
          seriesCovers,
        )..where((row) => row.seriesId.equals(seriesId)))
        .watchSingleOrNull()
        .whereNotNull()
        .distinct();
  }

  Stream<SeriesDetailWithRelations> watchSeriesDetail(int seriesId) {
    final volumesStream =
        (select(
                volumes,
              )
              ..where((row) => row.seriesId.equals(seriesId))
              ..orderBy([
                (volumes) => OrderingTerm.asc(volumes.minNumber),
                (volumes) => OrderingTerm.asc(volumes.maxNumber),
              ]))
            .watch();
    final chaptersQuery =
        (select(
            chapters,
          )
          ..where((row) => row.seriesId.equals(seriesId))
          ..orderBy([(chapters) => OrderingTerm.asc(chapters.sortOrder)]));
    final chaptersStream = chaptersQuery.watch();
    final specialsStream =
        (chaptersQuery..where((row) => row.isSpecial.equals(true))).watch();
    final storylineStream =
        (chaptersQuery..where((row) => row.isStoryline.equals(true))).watch();

    return Rx.combineLatest4(
      volumesStream,
      chaptersStream,
      specialsStream,
      storylineStream,
      (v, c, s, sl) => SeriesDetailWithRelations(
        volumes: v
            .map(
              (v) => VolumeWithRelations(
                volume: v,
                chapters: c.where((c) => c.volumeId == v.id).toList(),
              ),
            )
            .toList(),
        chapters: c,
        storylineChapters: sl,
        specials: s,
      ),
    );
  }

  Future<void> upsertSeries(SeriesCompanion entry) async {
    log.d('upserting series ${entry.id.value}');
    await into(series).insertOnConflictUpdate(entry);
  }

  Future<void> upsertSeriesBatch(Iterable<SeriesCompanion> entries) async {
    log.d('upserting series batch with ${entries.length} entries');
    await batch((batch) {
      batch.insertAllOnConflictUpdate(series, entries);
    });
  }

  Future<void> upsertSeriesDetail({
    required int seriesId,
    required SeriesDetailCompanions entries,
  }) async {
    await transaction(() async {
      await db.chaptersDao.clearSeriesChapters(seriesId: seriesId);
      await db.volumesDao.clearSeriesVolumes(seriesId: seriesId);
      await db.chaptersDao.upsertChapterBatch(entries.chapters);
      await db.chaptersDao.upsertChapterBatch(entries.specials);
      await db.chaptersDao.upsertChapterBatch(entries.storyline);
      await db.volumesDao.upsertVolumeBatch(entries.volumes);
    });
  }

  Future<void> upsertOnDeck(Iterable<SeriesCompanion> entries) async {
    await transaction(() async {
      await clearOnDeck();
      await upsertSeriesBatch(entries);
    });
  }

  Future<void> upsertRecentlyUpdated(Iterable<SeriesCompanion> entries) async {
    await transaction(() async {
      await clearIsRecentlyUpdated();
      await upsertSeriesBatch(entries);
    });
  }

  Future<void> upsertRecentlyAdded(Iterable<SeriesCompanion> entries) async {
    await transaction(() async {
      await clearIsRecentlyAdded();
      await upsertSeriesBatch(entries);
    });
  }

  Stream<bool> watchWantToRead(int seriesId) {
    return (select(series)..where((row) => row.id.equals(seriesId)))
        .watchSingleOrNull()
        .map((row) => row?.isWantToRead ?? false);
  }

  Stream<List<SeriesData>> watchWantToReadList() {
    return (select(series)..where((row) => row.isWantToRead)).watch();
  }

  Future<void> upsertWantToRead(int seriesId, {required bool value}) async {
    await (update(series)..where((row) => row.id.equals(seriesId))).write(
      SeriesCompanion(isWantToRead: Value(value)),
    );
  }

  Future<void> upsertSeriesCover(SeriesCoversCompanion cover) async {
    await into(seriesCovers).insertOnConflictUpdate(cover);
  }

  Future<void> clearOnDeck() async {
    await (update(series)..where((row) => row.isOnDeck)).write(
      const SeriesCompanion(isOnDeck: Value(false)),
    );
  }

  Future<void> clearIsRecentlyUpdated() async {
    await (update(series)..where((row) => row.isRecentlyUpdated)).write(
      const SeriesCompanion(isRecentlyUpdated: Value(false)),
    );
  }

  Future<void> clearIsRecentlyAdded() async {
    await (update(series)..where((row) => row.isRecentlyAdded)).write(
      const SeriesCompanion(isRecentlyAdded: Value(false)),
    );
  }

  Future<void> clearWantToRead() async {
    await (update(series)..where((row) => row.isWantToRead)).write(
      const SeriesCompanion(isWantToRead: Value(false)),
    );
  }
}

class SeriesDetailWithRelations {
  final List<VolumeWithRelations> volumes;
  final List<Chapter> specials;
  final List<Chapter> chapters;
  final List<Chapter> storylineChapters;

  const SeriesDetailWithRelations({
    required this.volumes,
    required this.specials,
    required this.chapters,
    required this.storylineChapters,
  });
}

class SeriesDetailCompanions {
  final Iterable<ChaptersCompanion> storyline;
  final Iterable<ChaptersCompanion> specials;
  final Iterable<ChaptersCompanion> chapters;
  final Iterable<VolumeWithChaptersCompanion> volumes;

  const SeriesDetailCompanions({
    required this.storyline,
    required this.specials,
    required this.chapters,
    required this.volumes,
  });
}
