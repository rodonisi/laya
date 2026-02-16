import 'dart:async';

import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/riverpod/repository/database.dart';
import 'package:hooks_riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storage_repository.g.dart';

@riverpod
Future<Storage<String, String>> storage(Ref ref) async {
  final db = ref.watch(databaseProvider);
  return StorageRepository(db: db);
}

final class StorageRepository extends Storage<String, String> {
  final AppDatabase _db;

  StorageRepository({required AppDatabase db}) : _db = db;

  FutureOr<void> clear() async {
    await _db.storageDao.clear();
  }

  @override
  FutureOr<void> delete(String key) async {
    await _db.storageDao.deleteKey(key);
  }

  @override
  FutureOr<void> deleteOutOfDate() async {
    await _db.storageDao.deleteOutOfDate();
  }

  @override
  FutureOr<PersistedData<String>?> read(String key) async {
    final entry = await _db.storageDao.read(key);

    if (entry == null) {
      return null;
    }

    return PersistedData(entry.data);
  }

  @override
  FutureOr<void> write(String key, String value, StorageOptions options) async {
    await _db.storageDao.write(
      RiverpodStorageCompanion(
        key: Value(key),
        data: Value(value),
        expireAt: Value(
          options.cacheTime.duration != null
              ? DateTime.timestamp().add(options.cacheTime.duration!)
              : null,
        ),
        destroyKey: Value(options.destroyKey),
      ),
    );
  }
}
