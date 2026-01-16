import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fluvita/api/models/library_dto.dart';

part 'library_model.freezed.dart';
part 'library_model.g.dart';

@freezed
sealed class LibraryModel with _$LibraryModel {
  const LibraryModel._();

  const factory LibraryModel({
    required int id,
    required String name,
  }) = _LibraryModel;

  factory LibraryModel.fromJson(Map<String, dynamic> json) =>
      _$LibraryModelFromJson(json);

  factory LibraryModel.fromLibraryDto(LibraryDto dto) {
    return LibraryModel(
      id: dto.id!,
      name: dto.name ?? 'Unnamed Library',
    );
  }
}
