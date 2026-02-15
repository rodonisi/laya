import 'package:drift/drift.dart';

class RiverpodStorage extends Table {
  TextColumn get key => text()();
  TextColumn get data => text()();
  DateTimeColumn get expireAt => dateTime().nullable()();
  TextColumn get destroyKey => text().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {key};
}
