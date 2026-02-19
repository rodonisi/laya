import 'package:drift/drift.dart';
import 'package:fluvita/database/tables/chapters.dart';
import 'package:fluvita/database/tables/libraries.dart';
import 'package:fluvita/database/tables/series.dart';
import 'package:fluvita/database/tables/volumes.dart';

/// Per-chapter reading progress (page position / scroll position).
@DataClassName('ReadingProgressData')
class ReadingProgress extends Table {
  IntColumn get chapterId => integer().references(Chapters, #id)();
  IntColumn get volumeId => integer().references(Volumes, #id)();
  IntColumn get seriesId => integer().references(Series, #id)();
  IntColumn get libraryId => integer().references(Libraries, #id)();
  IntColumn get pageNum => integer().withDefault(const Constant(0))();
  TextColumn get bookScrollId => text().nullable()();
  IntColumn get totalReads => integer().withDefault(const Constant(0))();
  DateTimeColumn get created => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastModified =>
      dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column<Object>>? get primaryKey => {chapterId};
}
