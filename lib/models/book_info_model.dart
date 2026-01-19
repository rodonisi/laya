import 'package:fluvita/api/openapi.swagger.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_info_model.freezed.dart';

enum BookInfoSeriesFormat {
  none,
  comic,
  manga,
  webtoon,
  book,
  unknown
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

  factory BookInfoModel.fromBookInfoDto(BookInfoDto dto) {
    return BookInfoModel(
      bookTitle: dto.bookTitle,
      seriesId: dto.seriesId,
      volumeId: dto.volumeId,
      seriesFormat: switch (dto.seriesFormat) {
        0 => BookInfoSeriesFormat.none,
        1 => BookInfoSeriesFormat.comic,
        2 => BookInfoSeriesFormat.manga,
        3 => BookInfoSeriesFormat.webtoon,
        4 => BookInfoSeriesFormat.book,
        _ => BookInfoSeriesFormat.unknown,
      },
      seriesName: dto.seriesName,
      chapterNumber: dto.chapterNumber,
      volumeNumber: dto.volumeNumber,
      libraryId: dto.libraryId,
      pages: dto.pages,
      isSpecial: dto.isSpecial,
      chapterTitle: dto.chapterTitle,
    );
  }
}
