import 'package:drift/drift.dart';
import 'package:fluvita/database/tables/series.dart';
import 'package:fluvita/database/tables/volumes.dart';
import 'package:fluvita/models/enums/format.dart';

class Chapters extends Table {
  IntColumn get id => integer()();
  IntColumn get volumeId => integer().references(Volumes, #id)();
  IntColumn get seriesId => integer().references(Series, #id)();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get summary => text().nullable()();
  TextColumn get isbn => text().nullable()();
  TextColumn get format => textEnum<Format>()();
  TextColumn get language => text().nullable()();
  RealColumn get sortOrder => real()();
  IntColumn get pages => integer()();
  IntColumn get wordCount => integer()();
  RealColumn get avgHoursToRead => real()();
  TextColumn get primaryColor => text().nullable()();
  TextColumn get secondaryColor => text().nullable()();
  IntColumn get totalReads => integer()();
  BoolColumn get isSpecial => boolean().withDefault(const Constant(false))();
  BoolColumn get isStoryline => boolean().withDefault(const Constant(false))();
  DateTimeColumn get releaseDate => dateTime()();

  DateTimeColumn get created => dateTime()();
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {id, volumeId, seriesId},
    {id, seriesId},
  ];
}

class ChapterCovers extends Table {
  IntColumn get chapterId => integer().references(Chapters, #id)();
  BlobColumn get image => blob()();

  @override
  Set<Column<Object>>? get primaryKey => {chapterId};
}
