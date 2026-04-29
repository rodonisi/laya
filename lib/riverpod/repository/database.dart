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


