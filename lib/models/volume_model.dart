import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fluvita/api/models/volume_dto.dart';
import 'package:fluvita/models/chapter_model.dart';

part 'volume_model.freezed.dart';
part 'volume_model.g.dart';

@freezed
sealed class VolumeModel with _$VolumeModel {
  const VolumeModel._();

  const factory VolumeModel({
    required int id,
    required String name,
    required int seriesId,
    required List<ChapterModel> chapters,
    required int pages,
    required int pagesRead,
  }) = _VolumeModel;

  factory VolumeModel.fromJson(Map<String, dynamic> json) =>
      _$VolumeModelFromJson(json);

  factory VolumeModel.fromVolumeDto(VolumeDto dto) {
    return VolumeModel(
      id: dto.id!,
      seriesId: dto.seriesId!,
      name: dto.name ?? 'Unnamed Volume',
      chapters: dto.chapters?.map(ChapterModel.fromChapterDto).toList() ?? [],
      pages: dto.pages!,
      pagesRead: dto.pagesRead!,
    );
  }

  double get progress {
    if (pages == 0) return 0.0;
    return pagesRead / pages;
  }
}
