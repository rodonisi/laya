import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/models/enums/format.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chapter_model.freezed.dart';
part 'chapter_model.g.dart';

@freezed
sealed class ChapterModel with _$ChapterModel {
  const ChapterModel._();

  const factory ChapterModel({
    required int id,
    required int volumeId,
    required String title,
    required int pages,
    required int totalReads,
    Format? format,
  }) = _ChapterModel;

  factory ChapterModel.fromJson(Map<String, Object?> json) =>
      _$ChapterModelFromJson(json);

  factory ChapterModel.fromDatabaseModel(Chapter table) {
    return ChapterModel(
      id: table.id,
      volumeId: table.volumeId,
      title: table.title ?? 'Untitled',
      pages: table.pages,
      totalReads: table.totalReads,
      format: table.format,
    );
  }
}
