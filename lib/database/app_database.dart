import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:fluvita/database/dao/storage_dao.dart';
import 'package:fluvita/database/tables/chapters.dart';
import 'package:fluvita/database/tables/riverpod_storage.dart';
import 'package:fluvita/database/tables/series.dart';
import 'package:fluvita/database/tables/downloaded_pages.dart';
import 'package:fluvita/database/tables/volumes.dart';
import 'package:fluvita/database/tables/pending_sync_operations.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:fluvita/utils/safe_platform.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Series, RiverpodStorage],
  daos: [StorageDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  Stream<List<Sery>> watchOnDeck() {
    return (select(series)..where((row) => row.isOnDeck)).watch();
  }

  Stream<List<Sery>> watchRecentlyUpdated() {
    return (select(series)..where((row) => row.isRecentlyUpdated)).watch();
  }

  Stream<List<Sery>> watchRecentlyAdded() {
    return (select(series)..where((row) => row.isRecentlyAdded)).watch();
  }

  Future<void> upsertSeries(SeriesCompanion entry) async {
    await into(series).insertOnConflictUpdate(entry);
  }

  Future<void> upsertSeriesBatch(Iterable<SeriesCompanion> entries) async {
    log.d('upserting series batch $entries');
    await batch((batch) {
      batch.insertAllOnConflictUpdate(series, entries);
    });
  }

  Future<void> upsertOnDeck(Iterable<SeriesCompanion> entries) async {
    await transaction(() async {
      await clearOnDeck();
      await upsertSeriesBatch(entries);
    });
  }

  Future<void> upsertRecentlyUpdated(Iterable<int> ids) async {
    await transaction(() async {
      await clearIsRecentlyUpdated();
      await (update(series)..where((row) => row.id.isIn(ids))).write(
        const SeriesCompanion(isRecentlyUpdated: Value(true)),
      );
    });
  }

  Future<void> upsertRecentlyAdded(Iterable<SeriesCompanion> entries) async {
    await transaction(() async {
      await clearIsRecentlyAdded();
      await upsertSeriesBatch(entries);
    });
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

  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(series).go();
    });
  }

  static QueryExecutor _openConnection() {
    if (SafePlatform.isWeb) {
      return NativeDatabase.memory();
    }
    return driftDatabase(
      name: 'fluvita_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
      // If you need web support, see https://drift.simonbinder.eu/platforms/web/
    );
  }
}
