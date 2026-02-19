import 'package:drift/drift.dart';
import 'package:fluvita/database/tables/chapters.dart';
import 'package:fluvita/database/tables/series.dart';
import 'package:fluvita/database/tables/volumes.dart';

/// Epub / book metadata for a chapter (one row per chapter).
class BookInfo extends Table {
  IntColumn get chapterId => integer().references(Chapters, #id)();
  TextColumn get bookTitle => text().nullable()();
  IntColumn get seriesId => integer().references(Series, #id).nullable()();
  IntColumn get volumeId => integer().references(Volumes, #id).nullable()();
  IntColumn get seriesFormat => integer().nullable()();
  TextColumn get seriesName => text().nullable()();
  TextColumn get chapterNumber => text().nullable()();
  TextColumn get volumeNumber => text().nullable()();
  IntColumn get libraryId => integer().nullable()();
  IntColumn get pages => integer().nullable()();
  BoolColumn get isSpecial => boolean().nullable()();
  TextColumn get chapterTitle => text().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {chapterId};
}

class BookChaptersTable extends Table {
  @override
  String get tableName => 'book_chapters';

  IntColumn get chapterId => integer().references(Chapters, #id)();
  TextColumn get title => text()();
  IntColumn get page => integer()();
  IntColumn get parentPage => integer().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {chapterId, page, title};
}
