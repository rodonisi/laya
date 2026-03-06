import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/libraries.dart';
import 'package:stream_transform/stream_transform.dart';

part 'libraries_dao.g.dart';

@DriftAccessor(tables: [Libraries])
class LibrariesDao extends DatabaseAccessor<AppDatabase>
    with _$LibrariesDaoMixin {
  LibrariesDao(super.attachedDatabase);

  /// Watch library [id]
  Stream<Library> watchLibrary(int id) {
    return managers.libraries
        .filter((f) => f.id(id))
        .watchSingleOrNull()
        .whereNotNull();
  }

  /// Watch all libraries stored in the db
  Stream<List<Library>> watchLibraries() {
    return managers.libraries.watch();
  }

  /// Upsert a batch of [LibrariesCompanion]
  Future<void> upsertLibraries(Iterable<LibrariesCompanion> entries) async {
    await batch((batch) => batch.insertAllOnConflictUpdate(libraries, entries));
  }
}
