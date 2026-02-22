import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/dao/series_metadata_dao.dart';

extension SeriesMetadataDtoMappings on SeriesMetadataDto {
  SeriesMetadataCompanions toSeriesMetadataCompanions() {
    return SeriesMetadataCompanions(
      metadata: SeriesMetadataCompanion(
        id: Value(id!),
        seriesId: Value(seriesId!),
        summary: Value(summary),
        ageRating: Value(ageRating ?? -1),
        releaseYear: Value(releaseYear ?? 0),
        language: Value(language ?? ''),
      ),
      writers:
          writers
              ?.map(
                (writer) => PeopleCompanion(
                  id: Value(writer.id!),
                  name: Value(writer.name!),
                ),
              )
              .toList() ??
          [],
      genres:
          genres
              ?.map(
                (genre) => GenresCompanion(
                  id: Value(genre.id!),
                  label: Value(genre.title!),
                ),
              )
              .toList() ??
          [],
      tags:
          tags?.map(
            (tag) => TagsCompanion(
              id: Value(tag.id!),
              label: Value(tag.title!),
            ),
          ) ??
          [],
    );
  }
}
