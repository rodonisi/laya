import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';

extension ReadingProgressDataMappings on ReadingProgressData {
  ProgressDto toProgressDto() {
    return ProgressDto(
      volumeId: volumeId,
      chapterId: chapterId,
      pageNum: pagesRead,
      seriesId: seriesId,
      libraryId: libraryId,
      bookScrollId: bookScrollId,
      lastModifiedUtc: lastModified,
    );
  }
}
