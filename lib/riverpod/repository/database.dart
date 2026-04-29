import 'dart:io';

import 'package:kover/riverpod/managers/sync_manager.dart';
import 'package:path/path.dart' as p;
import 'package:kover/database/app_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database.g.dart';

@Riverpod(keepAlive: true)
AppDatabase database(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(() {
    db.close();
  });
  return db;
}

@riverpod
Future<int> databaseSize(Ref ref) async {
  ref.watch(databaseDefragmentationProvider);
  ref.watch(syncManagerProvider);

  final applicationSubbportDir = await getApplicationSupportDirectory();
  final dbFile = File(
    p.join(applicationSubbportDir.path, '${AppDatabase.dbName}.sqlite'),
  );
  if (await dbFile.exists()) {
    final bytes = await dbFile.length();
    return bytes;
  } else {
    return 0;
  }
}

enum DefragmentationStatus {
  idle,
  busy,
  inProgress,
  completed,
  error,
}

@riverpod
class DatabaseDefragmentation extends _$DatabaseDefragmentation {
  @override
  Future<DefragmentationStatus> build() async {
    final syncing = ref.watch(
      syncManagerProvider.select((sync) => sync is SyncingState),
    );
    return syncing ? .busy : .idle;
  }

  Future<void> defragment() async {
    state = const AsyncData(.inProgress);
    try {
      final db = ref.read(databaseProvider);
      await db.defragment();
      state = const AsyncData(.completed);
    } catch (e) {
      state = const AsyncData(.error);
    }
  }
}
