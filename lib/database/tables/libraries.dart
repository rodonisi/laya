import 'package:drift/drift.dart';
import 'package:kover/models/enums/library_type.dart';

class Libraries extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get type => textEnum<LibraryType>()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}
