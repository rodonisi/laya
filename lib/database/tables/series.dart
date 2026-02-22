import 'package:drift/drift.dart';
import 'package:fluvita/database/tables/libraries.dart';
import 'package:fluvita/models/enums/format.dart';

@DataClassName('SeriesData')
class Series extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get originalName => text().nullable()();
  TextColumn get localizedName => text().nullable()();
  TextColumn get sortName => text().nullable()();
  IntColumn get libraryId => integer().references(Libraries, #id)();
  TextColumn get format => textEnum<Format>()();
  IntColumn get pages => integer().withDefault(const Constant(0))();
  IntColumn get wordCount => integer().withDefault(const Constant(0))();
  RealColumn get avgHoursToRead => real().nullable()();
  TextColumn get primaryColor => text().nullable()();
  TextColumn get secondaryColor => text().nullable()();

  BoolColumn get isOnDeck => boolean().withDefault(const Constant(false))();
  BoolColumn get isRecentlyAdded =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isRecentlyUpdated =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get created => dateTime()();
  DateTimeColumn get lastChapterAdded => dateTime().nullable()();
  DateTimeColumn get lastSynced => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {name, libraryId}, // Series name unique per library
  ];
}

class SeriesCovers extends Table {
  IntColumn get seriesId => integer().references(Series, #id)();
  BlobColumn get image => blob()();

  @override
  Set<Column<Object>>? get primaryKey => {seriesId};
}
