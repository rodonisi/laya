import 'package:kover/api/openapi.swagger.dart';
import 'package:kover/database/app_database.dart';

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
