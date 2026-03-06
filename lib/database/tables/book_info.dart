import 'package:drift/drift.dart';
import 'package:fluvita/database/tables/chapters.dart';

class BookChaptersTable extends Table {
  @override
  String get tableName => 'book_chapters';

  IntColumn get chapterId => integer().references(
    Chapters,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get title => text()();
  IntColumn get page => integer()();
  IntColumn get parentPage => integer().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {chapterId, page, title};
}
