import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/models/enums/library_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'library_model.freezed.dart';
part 'library_model.g.dart';

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

  factory LibraryModel.fromDatabaseModel(Library entity) {
    return LibraryModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
    );
  }
}
