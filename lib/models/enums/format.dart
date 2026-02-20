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
