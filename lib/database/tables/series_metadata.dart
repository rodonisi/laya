import 'package:drift/drift.dart';
import 'package:fluvita/database/tables/series.dart';

@DataClassName('SeriesMetadataData')
class SeriesMetadata extends Table {
  IntColumn get id => integer()();
  IntColumn get seriesId => integer().references(
    Series,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get summary => text().nullable()();
  IntColumn get ageRating => integer().withDefault(const Constant(-1))();
  IntColumn get releaseYear => integer()();
  TextColumn get language => text()();

  DateTimeColumn get lastUpdated =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {seriesId},
  ];
}

class People extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Genres extends Table {
  IntColumn get id => integer()();
  TextColumn get label => text()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Tags extends Table {
  IntColumn get id => integer()();
  TextColumn get label => text()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

enum PeopleRole { writer }

class SeriesPeopleRoles extends Table {
  IntColumn get seriesMetadataId => integer().references(SeriesMetadata, #id)();
  IntColumn get personId => integer().references(People, #id)();
  TextColumn get role => textEnum<PeopleRole>()();

  @override
  Set<Column<Object>>? get primaryKey => {seriesMetadataId, personId};
}

class SeriesGenres extends Table {
  IntColumn get seriesMetadataId => integer().references(SeriesMetadata, #id)();
  IntColumn get genreId => integer().references(Genres, #id)();

  @override
  Set<Column<Object>>? get primaryKey => {seriesMetadataId, genreId};
}

class SeriesTags extends Table {
  IntColumn get seriesMetadataId => integer().references(SeriesMetadata, #id)();
  IntColumn get tagId => integer().references(Tags, #id)();

  @override
  Set<Column<Object>>? get primaryKey => {seriesMetadataId, tagId};
}
