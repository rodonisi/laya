import 'package:drift/drift.dart';
import 'package:fluvita/database/tables/chapters.dart';

// class EpubPages extends Table {
//   IntColumn get chapterId => integer().references(Chapters, #id)();
//   IntColumn get page => integer()();
//   BlobColumn get data => blob().map(binaryConverter)();
//
//   DateTimeColumn get created => dateTime().withDefault(currentDateAndTime)();
//   DateTimeColumn get lastSync => dateTime().withDefault(currentDateAndTime)();
//
//   @override
//   Set<Column<Object>>? get primaryKey => {chapterId, page};
// }

class DownloadedPages extends Table {
  IntColumn get chapterId => integer().references(
    Chapters,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get page => integer()();
  BlobColumn get data => blob()();

  DateTimeColumn get created => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSync => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {chapterId, page};
}
