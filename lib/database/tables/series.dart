import 'package:drift/drift.dart';

enum Format {
  epub,
  archive,
  unknown
  ;

  factory Format.fromDtoFormat(int value) {
    return switch (value) {
      3 => Format.epub,
      1 => Format.archive,
      _ => Format.unknown,
    };
  }
}

@DataClassName('SeriesData')
class Series extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get originalName => text().nullable()();
  TextColumn get localizedName => text().nullable()();
  TextColumn get sortName => text().nullable()();
  IntColumn get libraryId => integer()();

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

  // Reading progress
  IntColumn get pagesRead => integer().withDefault(const Constant(0))();

  // Timestamps
  DateTimeColumn get created => dateTime()();
  DateTimeColumn get lastModified => dateTime().nullable()();
  DateTimeColumn get lastChapterAdded => dateTime().nullable()();
  DateTimeColumn get lastRead => dateTime().nullable()();

  // Offline support
  BoolColumn get isDownloaded => boolean().withDefault(const Constant(false))();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {name, libraryId}, // Series name unique per library
  ];
}
