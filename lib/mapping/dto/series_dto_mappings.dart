import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/models/enums/format.dart';

extension SeriesDtoMappings on SeriesDto {
  SeriesCompanion toSeriesCompanion() {
    return SeriesCompanion(
      id: Value(id!),
      name: Value(name!),
      originalName: Value(originalName),
      localizedName: Value(localizedName),
      sortName: Value(sortName!),
      libraryId: Value(libraryId!),
      format: Value(Format.fromDtoFormat(format!)),
      pages: Value(pages!),
      wordCount: Value(wordCount ?? 0),
      avgHoursToRead: Value(avgHoursToRead),
      primaryColor: Value(primaryColor),
      secondaryColor: Value(secondaryColor),
      created: Value.absentIfNull(created),
      lastChapterAdded: Value.absentIfNull(lastChapterAddedUtc),
      lastSynced: Value(DateTime.timestamp()),
    );
  }
}
