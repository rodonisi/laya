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

  /// Get series metadata for series [seriesId]
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

  /// Upsert batch of [SeriesMetadataCompanions]
  Future<void> upsertMetadataBatch(
    Iterable<SeriesMetadataCompanions> metadata,
  ) async {
    final meta = metadata.map((m) => m.metadata);
    final ws = metadata.map((m) => m.writers).expand((e) => e);
    final gs = metadata.map((m) => m.genres).expand((e) => e);
    final ts = metadata.map((m) => m.tags).expand((e) => e);

    await batch((batch) {
      batch.insertAllOnConflictUpdate(seriesMetadata, meta);
      batch.insertAllOnConflictUpdate(people, ws);
      batch.insertAllOnConflictUpdate(genres, gs);
      batch.insertAllOnConflictUpdate(tags, ts);
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

class SeriesMetadataCompanions {
  final SeriesMetadataCompanion metadata;
  final Iterable<PeopleCompanion> writers;
  final Iterable<GenresCompanion> genres;
  final Iterable<TagsCompanion> tags;

  SeriesMetadataCompanions({
    required this.metadata,
    required this.writers,
    required this.genres,
    required this.tags,
  });
}
