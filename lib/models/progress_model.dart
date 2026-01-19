import 'package:fluvita/api/openapi.swagger.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress_model.freezed.dart';

@freezed
sealed class ProgressModel with _$ProgressModel {
  const ProgressModel._();

  const factory ProgressModel({
    required int volumeId,
    required int chapterId,
    required int pageNum,
    required int seriesId,
    required int libraryId,
    String? bookScrollId,
    DateTime? lastModifiedUtc,
  }) = _ProgressModel;

  factory ProgressModel.fromProgressDto(ProgressDto dto) {
    return ProgressModel(
      volumeId: dto.volumeId,
      chapterId: dto.chapterId,
      pageNum: dto.pageNum,
      seriesId: dto.seriesId,
      libraryId: dto.libraryId,
      bookScrollId: dto.bookScrollId,
      lastModifiedUtc: dto.lastModifiedUtc,
    );
  }
}
