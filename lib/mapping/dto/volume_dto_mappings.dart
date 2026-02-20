import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/dao/volumes_dao.dart';
import 'package:fluvita/mapping/dto/chapter_dto_mappings.dart';

extension VolumeDtoMappings on VolumeDto {
  VolumeWithChaptersCompanion toVolumeCompanion() {
    return VolumeWithChaptersCompanion(
      volume: VolumesCompanion(
        id: Value(id!),
        seriesId: Value(seriesId!),
        minNumber: Value(minNumber!),
        maxNumber: Value(maxNumber!),
        name: Value.absentIfNull(name),
        wordCount: Value(wordCount!),
        pages: Value(pages!),
        avgHoursToRead: Value.absentIfNull(avgHoursToRead),
        primaryColor: Value.absentIfNull(primaryColor),
        secondaryColor: Value.absentIfNull(secondaryColor),
        created: Value.absentIfNull(createdUtc),
        lastModified: Value.absentIfNull(lastModifiedUtc),
      ),
      chapters: (chapters ?? []).map(
        (c) => c.toChapterCompanion().copyWith(
          seriesId: Value(seriesId!),
        ),
      ),
    );
  }
}
