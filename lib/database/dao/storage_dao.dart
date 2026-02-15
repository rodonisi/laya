import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/riverpod_storage.dart';

part 'storage_dao.g.dart';

@DriftAccessor(tables: [RiverpodStorage])
class StorageDao extends DatabaseAccessor<AppDatabase> with _$StorageDaoMixin {
  StorageDao(super.attachedDatabase);

  Future<void> clear() async {
    await delete(riverpodStorage).go();
  }

  Future<void> deleteKey(String key) async {
    await (delete(riverpodStorage)..where((row) => row.key.like(key))).go();
  }

  Future<void> deleteOutOfDate() async {
    await (delete(
      riverpodStorage,
    )..where((row) => row.expireAt.isSmallerThan(currentDateAndTime))).go();
  }

  Future<RiverpodStorageData?> read(String key) async {
    return (await (select(
      riverpodStorage,
    )..where((row) => row.key.like(key))).get()).firstOrNull;
  }

  Future<void> write(RiverpodStorageCompanion entry) async {
    await (into(riverpodStorage).insertOnConflictUpdate(entry));
  }
}
