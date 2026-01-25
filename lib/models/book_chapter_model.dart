import 'package:fluvita/api/openapi.swagger.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_chapter_model.freezed.dart';
part 'book_chapter_model.g.dart';

@freezed
sealed class BookChapterModel with _$BookChapterModel {
  const BookChapterModel._();

  const factory BookChapterModel({
    required String title,
    required int page,
    required List<BookChapterModel> children,
  }) = _BookChapterModel;

  factory BookChapterModel.fromJson(Map<String, dynamic> json) =>
      _$BookChapterModelFromJson(json);

  factory BookChapterModel.fromChapterItemDto(BookChapterItem dto) {
    return BookChapterModel(
      title: dto.title!,
      page: dto.page!,
      children:
          dto.children?.map(BookChapterModel.fromChapterItemDto).toList() ?? [],
    );
  }
}
