import 'package:fluvita/api/models/genre_tag_dto.dart';
import 'package:fluvita/api/models/person_dto.dart';
import 'package:fluvita/api/models/series_metadata_dto.dart';
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
    required double avgHoursToRead,
    required int? wordCount,
    required String? primaryColor,
    required String? secondaryColor,
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
      avgHoursToRead: dto.avgHoursToRead!,
      wordCount: dto.wordCount,
      primaryColor: dto.primaryColor,
      secondaryColor: dto.secondaryColor,
    );
  }

  double get progress {
    if (pages == 0) return 0.0;
    return pagesRead / pages;
  }
}

@freezed
sealed class SeriesDetailModel with _$SeriesDetailModel {
  const factory SeriesDetailModel({
    required int totalChapters,
    required List<ChapterModel> storyline,
    required List<VolumeModel> volumes,
    required List<ChapterModel> chapters,
    required List<ChapterModel> specials,
  }) = _SeriesDetailModel;

  factory SeriesDetailModel.fromJson(Map<String, Object?> json) =>
      _$SeriesDetailModelFromJson(json);

  factory SeriesDetailModel.fromSeriesDetailDto(SeriesDetailDto dto) {
    return SeriesDetailModel(
      totalChapters: dto.totalCount!,
      storyline:
          dto.storylineChapters?.map(ChapterModel.fromChapterDto).toList() ??
          [],
      volumes: dto.volumes?.map(VolumeModel.fromVolumeDto).toList() ?? [],
      chapters: dto.chapters?.map(ChapterModel.fromChapterDto).toList() ?? [],
      specials: dto.specials?.map(ChapterModel.fromChapterDto).toList() ?? [],
    );
  }
}

@freezed
sealed class PersonModel with _$PersonModel {
  const factory PersonModel({
    required int id,
    required String name,
  }) = _PersonModel;

  factory PersonModel.fromJson(Map<String, Object?> json) =>
      _$PersonModelFromJson(json);

  factory PersonModel.fromPersonDto(PersonDto dto) {
    return PersonModel(
      id: dto.id!,
      name: dto.name!,
    );
  }
}

@freezed
sealed class GenreModel with _$GenreModel {
  const factory GenreModel({
    required int id,
    required String name,
  }) = _GenreModel;

  factory GenreModel.fromJson(Map<String, Object?> json) =>
      _$GenreModelFromJson(json);

  factory GenreModel.fromGenreTagDto(GenreTagDto dto) {
    return GenreModel(
      id: dto.id!,
      name: dto.title!,
    );
  }
}

@freezed
sealed class SeriesMetadataModel with _$SeriesMetadataModel {
  const factory SeriesMetadataModel({
    required int seriesId,
    required int totalChapters,
    required int? releaseYear,
    required String? summary,
    required List<PersonModel> writers,
    required List<GenreModel> genres,
  }) = _SeriesMetadataModel;

  factory SeriesMetadataModel.fromJson(Map<String, Object?> json) =>
      _$SeriesMetadataModelFromJson(json);

  factory SeriesMetadataModel.fromSeriesMetadataDto(SeriesMetadataDto dto) {
    return SeriesMetadataModel(
      seriesId: dto.seriesId!,
      totalChapters: dto.totalCount!,
      releaseYear: dto.releaseYear,
      summary: dto.summary,
      writers: dto.writers?.map(PersonModel.fromPersonDto).toList() ?? [],
      genres: dto.genres?.map(GenreModel.fromGenreTagDto).toList() ?? [],
    );
  }
}
