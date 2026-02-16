import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/series_metadata.dart';
import 'package:stream_transform/stream_transform.dart';

part 'series_metadata_dao.g.dart';

@DriftAccessor(
  tables: [
    SeriesMetadata,
    People,
    Genres,
    Tags,
    SeriesPeopleRoles,
    SeriesGenres,
    SeriesTags,
  ],
)
class SeriesMetadataDao extends DatabaseAccessor<AppDatabase>
    with _$SeriesMetadataDaoMixin {
  SeriesMetadataDao(super.attachedDatabase);

  Stream<SeriesMetadataWithRelations> watchSeriesMetadata(int seriesId) {
    final query = select(seriesMetadata)
      ..where((row) => row.seriesId.equals(seriesId));

    return query.watchSingleOrNull().switchMap((metadata) async* {
      if (metadata == null) {
        yield SeriesMetadataWithRelations(
          metadata: null,
          writers: [],
          genres: [],
          tags: [],
        );
        return;
      }

      // Watch writers
      final writersQuery = select(people).join([
        innerJoin(
          seriesPeopleRoles,
          seriesPeopleRoles.personId.equalsExp(people.id) &
              seriesPeopleRoles.seriesMetadataId.equals(metadata.id),
        ),
      ]);

      // Watch genres
      final genresQuery = select(genres).join([
        innerJoin(
          seriesGenres,
          seriesGenres.genreId.equalsExp(genres.id) &
              seriesGenres.seriesMetadataId.equals(metadata.id),
        ),
      ]);

      final tagsQuery = select(tags).join([
        innerJoin(
          seriesTags,
          seriesTags.tagId.equalsExp(tags.id) &
              seriesTags.seriesMetadataId.equals(metadata.id),
        ),
      ]);

      await for (final _ in query.watch()) {
        final writersList = await writersQuery
            .map((row) => row.readTable(people))
            .get();
        final genresList = await genresQuery
            .map((row) => row.readTable(genres))
            .get();
        final tagsList = await tagsQuery
            .map((row) => row.readTable(tags))
            .get();

        yield SeriesMetadataWithRelations(
          metadata: metadata,
          writers: writersList,
          genres: genresList,
          tags: tagsList,
        );
      }
    });
  }

  Future<void> upsertMetadata(
    SeriesMetadataCompanion metadata, {
    Iterable<PeopleCompanion> writers = const [],
    Iterable<GenresCompanion> genres = const [],
    Iterable<TagsCompanion> tags = const [],
  }) async {
    await transaction(() async {
      await into(seriesMetadata).insertOnConflictUpdate(metadata);
      await (delete(
        seriesPeopleRoles,
      )..where((row) => row.seriesMetadataId.equals(metadata.id.value))).go();
      await (delete(
        seriesGenres,
      )..where((row) => row.seriesMetadataId.equals(metadata.id.value))).go();
      await (delete(
        seriesTags,
      )..where((row) => row.seriesMetadataId.equals(metadata.id.value))).go();

      await batch(
        (batch) {
          batch.insertAllOnConflictUpdate(people, writers);
          batch.insertAllOnConflictUpdate(
            seriesPeopleRoles,
            writers.map(
              (entry) => SeriesPeopleRolesCompanion(
                seriesMetadataId: metadata.id,
                personId: entry.id,
                role: const Value(.writer),
              ),
            ),
          );
        },
      );
      await batch(
        (batch) {
          batch.insertAllOnConflictUpdate(this.genres, genres);
          batch.insertAllOnConflictUpdate(
            seriesGenres,
            genres.map(
              (entry) => SeriesGenresCompanion(
                seriesMetadataId: metadata.id,
                genreId: entry.id,
              ),
            ),
          );
        },
      );
      await batch(
        (batch) {
          batch.insertAllOnConflictUpdate(this.tags, tags);
          batch.insertAllOnConflictUpdate(
            seriesTags,
            tags.map(
              (entry) => SeriesTagsCompanion(
                seriesMetadataId: metadata.id,
                tagId: entry.id,
              ),
            ),
          );
        },
      );
    });
  }
}

class SeriesMetadataWithRelations {
  final SeriesMetadataData? metadata;
  final List<PeopleData> writers;
  final List<Genre> genres;
  final List<Tag> tags;

  SeriesMetadataWithRelations({
    required this.metadata,
    required this.writers,
    required this.genres,
    required this.tags,
  });
}
