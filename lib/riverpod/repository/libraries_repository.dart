import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/models/enums/library_type.dart';
import 'package:fluvita/models/library_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/repository/database.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'libraries_repository.g.dart';

@riverpod
LibrariesRepository librariesRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final restClient = ref.watch(restClientProvider);

  return LibrariesRepository(
    db: db,
    client: LibrariesRemoteOperations(restClient),
  );
}

class LibrariesRepository {
  final AppDatabase _db;
  final LibrariesRemoteOperations _client;

  const LibrariesRepository({
    required AppDatabase db,
    required LibrariesRemoteOperations client,
  }) : _db = db,
       _client = client;

  Stream<LibraryModel> watchLibrary(int id) {
    return _db.librariesDao
        .watchLibrary(id)
        .map(LibraryModel.fromDatabaseModel);
  }

  Stream<List<LibraryModel>> watchLibraries() {
    return _db.librariesDao.watchLibraries().map(
      (entries) => entries.map(LibraryModel.fromDatabaseModel).toList(),
    );
  }

  Future<void> refreshLibraries() async {
    try {
      final libraries = await _client.getLibraries();
      _db.librariesDao.upsertLibraries(libraries);
    } catch (e) {
      log.e('Failed fetching libraries', error: e);
    }
  }
}

class LibrariesRemoteOperations {
  final Openapi _client;
  const LibrariesRemoteOperations(this._client);

  Future<Iterable<LibrariesCompanion>> getLibraries() async {
    final res = await _client.apiLibraryLibrariesGet();

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load libraries: ${res.error}');
    }

    return res.body!.map(mapLibrariesCompanion);
  }

  static LibrariesCompanion mapLibrariesCompanion(LibraryDto dto) {
    return LibrariesCompanion(
      id: Value(dto.id!),
      name: Value(dto.name!),
      type: Value(LibraryType.fromDtoType(dto.type!)),
    );
  }
}
