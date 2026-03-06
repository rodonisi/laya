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
    return managers.seriesMetadata
        .withReferences(
          (prefetch) => prefetch(
            seriesGenresRefs: true,
            seriesPeopleRolesRefs: true,
            seriesTagsRefs: true,
          ),
        )
        .filter((f) => f.seriesId.id(seriesId))
        .asyncMap(
          (m) async {
            final (metadata, refs) = m;
            final writersIds =
                refs.seriesPeopleRolesRefs.prefetchedData
                    ?.where((p) => p.role == .writer)
                    .map((p) => p.personId) ??
                [];
            final genresIds =
                refs.seriesGenresRefs.prefetchedData?.map((e) => e.genreId) ??
                [];
            final tagIds =
                refs.seriesTagsRefs.prefetchedData?.map((e) => e.tagId) ?? [];

            return SeriesMetadataWithRelations(
              metadata: metadata,
              writers: await managers.people
                  .filter((f) => f.id.isIn(writersIds))
                  .get(),

              genres: await managers.genres
                  .filter((f) => f.id.isIn(genresIds))
                  .get(),
              tags: await managers.tags.filter((f) => f.id.isIn(tagIds)).get(),
            );
          },
        )
        .watchSingleOrNull()
        .whereNotNull();
  }

  /// Get the list of series ids without metadata
  Future<List<int>> getMissingSeriesIds() async {
    final query =
        select(series).join([
          leftOuterJoin(
            seriesMetadata,
            seriesMetadata.seriesId.equalsExp(series.id),
          ),
        ])..where(
          seriesMetadata.seriesId.isNull() |
              seriesMetadata.lastUpdated.isSmallerThan(series.lastChapterAdded),
        );

    return await query.map((row) => row.readTable(series).id).get();
  }

  /// Upsert batch of [SeriesMetadataCompanions]
  Future<void> upsertMetadataBatch(
    Iterable<SeriesMetadataCompanions> metadata,
  ) async {
    final items = metadata.toList();
    final meta = items.map((m) => m.metadata);
    final ws = items.map((m) => m.writers).expand((e) => e);
    final gs = items.map((m) => m.genres).expand((e) => e);
    final ts = items.map((m) => m.tags).expand((e) => e);
    final prs = items.map((m) => m.peopleRoles).expand((e) => e);
    final sgs = items.map((m) => m.seriesGenres).expand((e) => e);
    final sts = items.map((m) => m.seriesTags).expand((e) => e);

    await batch((batch) {
      batch.insertAllOnConflictUpdate(seriesMetadata, meta);
      batch.insertAllOnConflictUpdate(people, ws);
      batch.insertAllOnConflictUpdate(genres, gs);
      batch.insertAllOnConflictUpdate(tags, ts);
      batch.insertAllOnConflictUpdate(seriesPeopleRoles, prs);
      batch.insertAllOnConflictUpdate(seriesGenres, sgs);
      batch.insertAllOnConflictUpdate(seriesTags, sts);
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
  final Iterable<SeriesPeopleRolesCompanion> peopleRoles;
  final Iterable<SeriesGenresCompanion> seriesGenres;
  final Iterable<SeriesTagsCompanion> seriesTags;

  SeriesMetadataCompanions({
    required this.metadata,
    required this.writers,
    required this.genres,
    required this.tags,
    required this.peopleRoles,
    required this.seriesGenres,
    required this.seriesTags,
  });
}
