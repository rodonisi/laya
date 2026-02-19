import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/libraries.dart';
import 'package:stream_transform/stream_transform.dart';

part 'libraries_dao.g.dart';

@DriftAccessor(tables: [Libraries])
class LibrariesDao extends DatabaseAccessor<AppDatabase>
    with _$LibrariesDaoMixin {
  LibrariesDao(super.attachedDatabase);

  Stream<Library> watchLibrary(int id) {
    return (select(
          libraries,
        )..where((row) => row.id.equals(id)))
        .watchSingleOrNull()
        .whereNotNull()
        .distinct();
  }

  Stream<List<Library>> watchLibraries() {
    return (select(libraries)).watch().distinct();
  }

  Future<void> upsertLibraries(Iterable<LibrariesCompanion> entries) async {
    await batch((batch) => batch.insertAllOnConflictUpdate(libraries, entries));
  }
}
