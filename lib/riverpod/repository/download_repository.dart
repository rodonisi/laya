import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/riverpod/providers/client.dart';
import 'package:fluvita/riverpod/repository/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_repository.g.dart';

@riverpod
DownloadRepository downloadRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final client = ref.watch(restClientProvider);

  return DownloadRepository(db: db, client: DownloadSyncOperations(client));
}

class DownloadRepository {
  final AppDatabase _db;
  final DownloadSyncOperations _client;

  const DownloadRepository({
    required AppDatabase db,
    required DownloadSyncOperations client,
  }) : _db = db,
       _client = client;
}

class DownloadSyncOperations {
  final Openapi _client;

  const DownloadSyncOperations(this._client);
}
