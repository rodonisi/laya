import 'package:drift/drift.dart';
import 'package:fluvita/database/tables/series.dart';

class WantToRead extends Table {
  IntColumn get seriesId => integer().references(Series, #id)();

  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>>? get primaryKey => {seriesId};
}
