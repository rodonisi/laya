import 'package:drift/drift.dart';
import 'package:fluvita/database/tables/series.dart';

class Volumes extends Table {
  IntColumn get id => integer()();
  IntColumn get seriesId => integer().references(Series, #id)();
  TextColumn get name => text().nullable()();
  IntColumn get wordCount => integer().withDefault(const Constant(0))();
  IntColumn get pages => integer()();
  IntColumn get pagesRead => integer()();
  RealColumn get avgHoursToRead => real().nullable()();
  TextColumn get primaryColor => text().nullable()();
  TextColumn get secondaryColor => text().nullable()();
  DateTimeColumn get created => dateTime()();
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class VolumeCovers extends Table {
  IntColumn get volumeId => integer().references(Volumes, #id)();
  BlobColumn get image => blob()();

  @override
  Set<Column<Object>>? get primaryKey => {volumeId};
}
