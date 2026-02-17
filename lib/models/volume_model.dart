import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
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
    double? avgHoursToRead,
    int? wordCount,
    String? primaryColor,
    String? secondaryColor,
  }) = _VolumeModel;

  factory VolumeModel.fromJson(Map<String, dynamic> json) =>
      _$VolumeModelFromJson(json);

  factory VolumeModel.fromVolumeDto(VolumeDto dto) {
    return VolumeModel(
      id: dto.id!,
      seriesId: dto.seriesId!,
      name: dto.name!,
      chapters: dto.chapters?.map(ChapterModel.fromChapterDto).toList() ?? [],
      pages: dto.pages!,
      pagesRead: dto.pagesRead!,
      avgHoursToRead: dto.avgHoursToRead,
      wordCount: dto.wordCount,
      primaryColor: dto.primaryColor,
      secondaryColor: dto.secondaryColor,
    );
  }

  factory VolumeModel.fromDatabaseModel(Volume table) {
    return VolumeModel(
      id: table.id,
      seriesId: table.seriesId,
      name: table.name ?? '',
      chapters: [],
      pages: 0,
      pagesRead: 0,
      avgHoursToRead: null,
      wordCount: table.wordCount,
      primaryColor: table.primaryColor,
      secondaryColor: table.secondaryColor,
    );
  }

  double get progress {
    if (pages == 0) return 0.0;
    return pagesRead / pages;
  }
}
