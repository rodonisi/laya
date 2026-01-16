import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fluvita/api/export.dart';

part 'chapter_model.freezed.dart';
part 'chapter_model.g.dart';

@freezed
sealed class ChapterModel with _$ChapterModel {
  const factory ChapterModel({
    required int id,
    required int volumeId,
    required String title,
  }) = _ChapterModel;

  factory ChapterModel.fromJson(Map<String, Object?> json) =>
      _$ChapterModelFromJson(json);

  factory ChapterModel.fromChapterDto(ChapterDto dto) {
    return ChapterModel(
      id: dto.id!,
      volumeId: dto.volumeId!,
      title: dto.titleName ?? 'Untitled',
    );
  }
}
