import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/riverpod/providers/client.dart';
import 'package:fluvita/riverpod/repository/database.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'series_metadata_repository.g.dart';

@riverpod
SeriesMetadataRepository seriesMetadataRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final client = SeriesMetadataRemoteOperations(ref.watch(restClientProvider));
  return SeriesMetadataRepository(db, client);
}

class SeriesMetadataRepository {
  final AppDatabase _db;
  final SeriesMetadataRemoteOperations _client;

  SeriesMetadataRepository(this._db, this._client);

  Stream<SeriesMetadataModel> watchSeriesMetadata(int seriesId) {
    refreshSeriesMetadata(seriesId);
    return _db.seriesMetadataDao
        .watchSeriesMetadata(seriesId)
        .map(SeriesMetadataModel.fromDatabaseModel);
  }

  Future<void> refreshSeriesMetadata(int seriesId) async {
    try {
      final metadata = await _client.getSeriesMetadata(seriesId);
      await _db.seriesMetadataDao.upsertMetadata(
        metadata.metadata,
        writers: metadata.writers,
        genres: metadata.genres,
        tags: metadata.tags,
      );
    } catch (e) {
      log.e(e);
    }
  }
}

class SeriesMetadataRemoteOperations {
  final Openapi _client;

  const SeriesMetadataRemoteOperations(this._client);

  Future<SeriesMetadataWithRelations> getSeriesMetadata(int seriesId) async {
    final res = await _client.apiSeriesMetadataGet(seriesId: seriesId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load series metadata: ${res.error}');
    }

    final dto = res.body!;

    return SeriesMetadataWithRelations(
      metadata: SeriesMetadataCompanion(
        id: Value(dto.id!),
        seriesId: Value(dto.seriesId!),
        summary: Value(dto.summary),
        ageRating: Value(dto.ageRating ?? -1),
        releaseYear: Value(dto.releaseYear ?? 0),
        language: Value(dto.language ?? ''),
      ),
      writers:
          dto.writers
              ?.map(
                (writer) => PeopleCompanion(
                  id: Value(writer.id!),
                  name: Value(writer.name!),
                ),
              )
              .toList() ??
          [],
      genres:
          dto.genres
              ?.map(
                (genre) => GenresCompanion(
                  id: Value(genre.id!),
                  label: Value(genre.title!),
                ),
              )
              .toList() ??
          [],
      tags:
          dto.tags?.map(
            (tag) => TagsCompanion(
              id: Value(tag.id!),
              label: Value(tag.title!),
            ),
          ) ??
          [],
    );
  }
}

class SeriesMetadataWithRelations {
  final SeriesMetadataCompanion metadata;
  final Iterable<PeopleCompanion> writers;
  final Iterable<GenresCompanion> genres;
  final Iterable<TagsCompanion> tags;

  SeriesMetadataWithRelations({
    required this.metadata,
    required this.writers,
    required this.genres,
    required this.tags,
  });
}
