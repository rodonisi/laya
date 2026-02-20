import 'package:drift/drift.dart';
import 'package:fluvita/database/tables/chapters.dart';

class EpubPages extends Table {
  IntColumn get chapterId => integer().references(Chapters, #id)();
  IntColumn get page => integer()();
  TextColumn get data => text()();

  DateTimeColumn get created => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSync => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {chapterId, page};
}

class ImagePages extends Table {
  IntColumn get chapterId => integer().references(Chapters, #id)();
  IntColumn get page => integer()();
  BlobColumn get data => blob()();

  DateTimeColumn get created => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSync => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {chapterId, page};
}
