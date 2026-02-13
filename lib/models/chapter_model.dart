import 'package:fluvita/models/series_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fluvita/api/openapi.swagger.dart';

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
    required int pagesRead,
    required int totalReads,
    Format? format,
  }) = _ChapterModel;

  factory ChapterModel.fromJson(Map<String, Object?> json) =>
      _$ChapterModelFromJson(json);

  factory ChapterModel.fromChapterDto(ChapterDto dto) {
    return ChapterModel(
      id: dto.id!,
      volumeId: dto.volumeId!,
      title: dto.titleName ?? 'Untitled',
      pages: dto.pages!,
      pagesRead: dto.pagesRead!,
      totalReads: dto.totalReads ?? 0,
      format: dto.format != null ? Format.fromDtoFormat(dto.format!) : null,
    );
  }

  double get progress {
    if (pages == 0) return 0.0;
    return pagesRead / pages;
  }
}
