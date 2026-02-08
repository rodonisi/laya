import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fluvita/api/openapi.swagger.dart';

part 'library_model.freezed.dart';
part 'library_model.g.dart';

enum LibraryType {
  unknown,
  book,
  comic,
  image,
  lightNovel,
  manga,
}

@freezed
sealed class LibraryModel with _$LibraryModel {
  const LibraryModel._();

  const factory LibraryModel({
    required int id,
    required String name,
    required LibraryType type,
  }) = _LibraryModel;

  factory LibraryModel.fromJson(Map<String, dynamic> json) =>
      _$LibraryModelFromJson(json);

  factory LibraryModel.fromLibraryDto(LibraryDto dto) {
    return LibraryModel(
      id: dto.id!,
      name: dto.name!,
      type: switch (dto.type!) {
        2 => .book,
        0 => .manga,
        5 => .comic,
        _ => .unknown,
      },
    );
  }
}
