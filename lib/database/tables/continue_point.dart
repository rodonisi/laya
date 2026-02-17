import 'package:drift/drift.dart';
import 'package:fluvita/database/tables/chapters.dart';
import 'package:fluvita/database/tables/series.dart';

class ContinuePoints extends Table {
  IntColumn get seriesId => integer().references(Series, #id)();
  IntColumn get chapterId => integer().references(Chapters, #id)();

  @override
  Set<Column<Object>>? get primaryKey => {seriesId};
}
