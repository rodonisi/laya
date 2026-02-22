import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/dao/volumes_dao.dart';
import 'package:fluvita/database/tables/progress.dart';
import 'package:fluvita/database/tables/series.dart';
import 'package:fluvita/database/tables/volumes.dart';
import 'package:fluvita/database/tables/chapters.dart';
import 'package:fluvita/database/tables/want_to_read.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:rxdart/rxdart.dart';

part 'series_dao.g.dart';

@DriftAccessor(
  tables: [
    Series,
    SeriesCovers,
    Volumes,
    Chapters,
    ReadingProgress,
    WantToRead,
  ],
)
class SeriesDao extends DatabaseAccessor<AppDatabase> with _$SeriesDaoMixin {
  SeriesDao(super.attachedDatabase);

  Stream<SeriesData> watchSeries(int seriesId) {
    return managers.series
        .filter((s) => s.id(seriesId))
        .watchSingleOrNull()
        .whereNotNull()
        .distinct();
  }

  Stream<int?> watchPagesRead({required int seriesId}) {
    final pagesReadSum = readingProgress.pagesRead.sum();

    final query = selectOnly(readingProgress)
      ..addColumns([pagesReadSum])
      ..where(readingProgress.seriesId.equals(seriesId))
      ..groupBy([readingProgress.seriesId]);

    return query.watchSingleOrNull().map((row) => row?.read(pagesReadSum));
  }

  MultiSelectable<SeriesData> allSeries({int? libraryId}) {
    final query = select(series);
    if (libraryId != null) {
      return (query..where((row) => row.libraryId.equals(libraryId)));
    }

    return query;
  }

  MultiSelectable<Chapter> allChapters({required int seriesId}) {
    return managers.chapters.filter((f) => f.seriesId.id(seriesId));
  }

  Stream<List<SeriesData>> watchOnDeck() {
    return managers.series
        .filter((f) => f.isOnDeck(true))
        .orderBy((o) => o.lastRead.desc())
        .watch();
  }

  Stream<List<SeriesData>> watchRecentlyUpdated() {
    return managers.series
        .filter((f) => f.isRecentlyUpdated(true))
        .orderBy((o) => o.lastChapterAdded.desc())
        .watch();
  }

  Stream<List<SeriesData>> watchRecentlyAdded() {
    return managers.series
        .filter((f) => f.isRecentlyAdded(true))
        .orderBy((o) => o.created.desc())
        .watch();
  }

  Stream<SeriesCover> watchSeriesCover({required int seriesId}) {
    return managers.seriesCovers
        .filter((f) => f.seriesId.id(seriesId))
        .watchSingleOrNull()
        .whereNotNull()
        .distinct();
  }

  Stream<SeriesDetailWithRelations> watchSeriesDetail(int seriesId) {
    final volumesStream = managers.volumes
        .filter((f) => f.seriesId.id(seriesId))
        .orderBy((o) => o.minNumber.asc() & o.maxNumber.asc())
        .withReferences((fetch) => fetch(chaptersRefs: true))
        .map(
          (m) => VolumeWithRelations(
            volume: m.$1,
            chapters: m.$2.chaptersRefs.prefetchedData ?? [],
          ),
        )
        .watch();

    final baseChaptersManager = managers.chapters
        .filter((f) => f.seriesId.id(seriesId))
        .orderBy((o) => o.sortOrder.asc());

    final chaptersStream = baseChaptersManager.watch();

    final specialsStream = baseChaptersManager
        .filter((f) => f.isSpecial.equals(true))
        .watch();

    final storylineStream = baseChaptersManager
        .filter((f) => f.isStoryline.equals(true))
        .watch();

    return Rx.combineLatest4(
      volumesStream,
      chaptersStream,
      specialsStream,
      storylineStream,
      (vList, cList, sList, slList) => SeriesDetailWithRelations(
        volumes: vList,
        chapters: cList,
        storylineChapters: slList,
        specials: sList,
      ),
    );
  }

  Future<List<int>> getMissingCovers() async {
    final query = select(series).join([
      leftOuterJoin(seriesCovers, seriesCovers.seriesId.equalsExp(series.id)),
    ]);

    query.where(seriesCovers.seriesId.isNull());

    return await query.map((row) => row.readTable(series).id).get();
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
      await db.chaptersDao.upsertChapterBatch({
        ...entries.chapters,
        ...entries.specials,
        ...entries.storyline,
      });
      await db.volumesDao.upsertVolumeBatch(entries.volumes);

      final s = await (select(
        series,
      )..where((tbl) => tbl.id.equals(seriesId))).getSingle();

      final progress = entries.progress.map(
        (c) => c.copyWith(
          seriesId: Value(seriesId),
          libraryId: Value(s.libraryId),
          dirty: const Value(false),
        ),
      );

      await db.readerDao.upsertCleanProgressBatch(progress);
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
    return managers.wantToRead
        .filter((f) => f.seriesId.id(seriesId))
        .watchSingleOrNull()
        .map((i) => i != null && i.isWantToRead);
  }

  Stream<List<SeriesData>> watchWantToReadList() {
    return select(wantToRead)
        .join([innerJoin(series, series.id.equalsExp(wantToRead.seriesId))])
        .map((res) => res.readTable(series))
        .watch();
  }

  Future<List<WantToReadData>> getDirtyWantToRead() async {
    return await managers.wantToRead.filter((f) => f.dirty(true)).get();
  }

  Future<void> upsertWantToRead(WantToReadCompanion entry) async {
    await into(wantToRead).insertOnConflictUpdate(entry);
  }

  Future<void> upsertWantToReadBatch(
    Iterable<WantToReadCompanion> entries,
  ) async {
    await batch(
      (batch) => batch.insertAllOnConflictUpdate(wantToRead, entries),
    );
  }

  Future<void> removeWantToRead({required int seriesId}) async {
    await (update(
      wantToRead,
    )..where((tbl) => tbl.seriesId.equals(seriesId))).write(
      const WantToReadCompanion(isWantToRead: Value(true), dirty: Value(true)),
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
    await delete(wantToRead).go();
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
  final Iterable<ReadingProgressCompanion> progress;

  const SeriesDetailCompanions({
    required this.storyline,
    required this.specials,
    required this.chapters,
    required this.volumes,
    required this.progress,
  });
}
