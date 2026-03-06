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
