import 'package:fluvita/database/app_database.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress_model.freezed.dart';
part 'progress_model.g.dart';

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
    DateTime? lastModified,
  }) = _ProgressModel;

  factory ProgressModel.fromJson(Map<String, dynamic> json) =>
      _$ProgressModelFromJson(json);

  factory ProgressModel.fromDatabaseModel(ReadingProgressData row) {
    return ProgressModel(
      volumeId: row.volumeId,
      chapterId: row.chapterId,
      pageNum: row.pagesRead,
      seriesId: row.seriesId,
      libraryId: row.libraryId,
      bookScrollId: row.bookScrollId,
      lastModified: row.lastModified,
    );
  }
}
