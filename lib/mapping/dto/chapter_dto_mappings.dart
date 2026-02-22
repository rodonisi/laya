import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/models/enums/format.dart';

extension ChapterDtoMappings on ChapterDto {
  /// Map available to a [ReadingProgressCompanion].
  /// seriesId, libraryId, scrollId will missing from the companion.
  ReadingProgressCompanion toPartialReadingProgressCompanion() {
    return ReadingProgressCompanion(
      chapterId: Value(id!),
      volumeId: Value(id!),
      pagesRead: Value(pagesRead!),
      totalReads: Value(totalReads!),
    );
  }

  ChaptersCompanion toChapterCompanion() {
    return ChaptersCompanion(
      id: Value(id!),
      volumeId: Value(volumeId!),
      title: Value(titleName),
      description: Value(summary),
      summary: Value(summary),
      isbn: Value(isbn),
      format: Value(
        format != null ? Format.fromDtoFormat(format!) : .unknown,
      ),
      language: Value.absentIfNull(language),
      sortOrder: Value.absentIfNull(sortOrder),
      pages: Value(pages!),
      wordCount: Value.absentIfNull(wordCount),
      avgHoursToRead: Value.absentIfNull(avgHoursToRead),
      primaryColor: Value.absentIfNull(primaryColor),
      secondaryColor: Value.absentIfNull(secondaryColor),
      totalReads: Value.absentIfNull(totalReads),
      isSpecial: Value.absentIfNull(isSpecial),
      releaseDate: Value.absentIfNull(releaseDate),
      created: Value.absentIfNull(createdUtc),
      lastModified: Value.absentIfNull(lastModifiedUtc),
    );
  }
}
