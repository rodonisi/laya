import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_info_model.freezed.dart';
part 'book_info_model.g.dart';

enum BookInfoSeriesFormat {
  none,
  comic,
  manga,
  webtoon,
  book,
  unknown;

  factory BookInfoSeriesFormat.fromDtoValue(int? value) => switch (value) {
    0 => none,
    1 => comic,
    2 => manga,
    3 => webtoon,
    4 => book,
    _ => unknown,
  };
}

@freezed
sealed class BookInfoModel with _$BookInfoModel {
  const BookInfoModel._();

  const factory BookInfoModel({
    String? bookTitle,
    int? seriesId,
    int? volumeId,
    BookInfoSeriesFormat? seriesFormat,
    String? seriesName,
    String? chapterNumber,
    String? volumeNumber,
    int? libraryId,
    int? pages,
    bool? isSpecial,
    String? chapterTitle,
  }) = _BookInfoModel;

  factory BookInfoModel.fromJson(Map<String, dynamic> json) =>
      _$BookInfoModelFromJson(json);

  factory BookInfoModel.fromBookInfoDto(BookInfoDto dto) {
    return BookInfoModel(
      bookTitle: dto.bookTitle,
      seriesId: dto.seriesId,
      volumeId: dto.volumeId,
      seriesFormat: BookInfoSeriesFormat.fromDtoValue(dto.seriesFormat),
      seriesName: dto.seriesName,
      chapterNumber: dto.chapterNumber,
      volumeNumber: dto.volumeNumber,
      libraryId: dto.libraryId,
      pages: dto.pages,
      isSpecial: dto.isSpecial,
      chapterTitle: dto.chapterTitle,
    );
  }

  factory BookInfoModel.fromDatabaseModel(BookInfoData row) {
    return BookInfoModel(
      bookTitle: row.bookTitle,
      seriesId: row.seriesId,
      volumeId: row.volumeId,
      seriesFormat: BookInfoSeriesFormat.fromDtoValue(row.seriesFormat),
      seriesName: row.seriesName,
      chapterNumber: row.chapterNumber,
      volumeNumber: row.volumeNumber,
      libraryId: row.libraryId,
      pages: row.pages,
      isSpecial: row.isSpecial,
      chapterTitle: row.chapterTitle,
    );
  }
}
