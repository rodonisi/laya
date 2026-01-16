import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fluvita/api/models/series_detail_dto.dart';
import 'package:fluvita/api/models/series_dto.dart';
import 'package:fluvita/models/chapter_model.dart';
import 'package:fluvita/models/volume_model.dart';

part 'series_model.freezed.dart';
part 'series_model.g.dart';

enum Format { epub, cbz, unknown }

@freezed
sealed class SeriesModel with _$SeriesModel {
  const SeriesModel._();

  const factory SeriesModel({
    required int id,
    required int libraryId,
    required String name,
    required Format format,
    required int pages,
    required int pagesRead,
  }) = _SeriesModel;

  factory SeriesModel.fromJson(Map<String, Object?> json) =>
      _$SeriesModelFromJson(json);

  factory SeriesModel.fromSeriesDto(SeriesDto dto) {
    return SeriesModel(
      id: dto.id!,
      libraryId: dto.libraryId!,
      name: dto.name ?? 'Untitled',
      format: switch (dto.format) {
        .value3 => Format.epub,
        .value1 => Format.cbz,
        _ => Format.unknown,
      },
      pages: dto.pages!,
      pagesRead: dto.pagesRead!,
    );
  }
}

@freezed
sealed class SeriesDetailModel with _$SeriesDetailModel {
  const factory SeriesDetailModel({
    required List<VolumeModel> volumes,
    required List<ChapterModel> chapters,
    required List<ChapterModel> specials,
  }) = _SeriesDetailModel;

  factory SeriesDetailModel.fromJson(Map<String, Object?> json) =>
      _$SeriesDetailModelFromJson(json);

  factory SeriesDetailModel.fromSeriesDetailDto(SeriesDetailDto dto) {
    return SeriesDetailModel(
      volumes: dto.volumes?.map(VolumeModel.fromVolumeDto).toList() ?? [],
      chapters: dto.chapters?.map(ChapterModel.fromChapterDto).toList() ?? [],
      specials: dto.specials?.map(ChapterModel.fromChapterDto).toList() ?? [],
    );
  }
}
