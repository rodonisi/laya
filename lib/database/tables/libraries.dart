import 'package:drift/drift.dart';

enum LibraryType {
  unknown,
  book,
  comic,
  image,
  lightNovel,
  manga
  ;

  factory LibraryType.fromDtoType(int type) => switch (type) {
    2 => .book,
    0 => .manga,
    5 => .comic,
    _ => .unknown,
  };
}

class Libraries extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get type => textEnum<LibraryType>()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}
