import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/series.dart';
import 'package:fluvita/models/chapter_model.dart';
import 'package:fluvita/models/image_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/repository/database.dart';
import 'package:fluvita/riverpod/settings.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chapters_repository.g.dart';

@riverpod
ChaptersRepository chaptersRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final restClient = ref.watch(restClientProvider);
  final apiKey = ref.watch(apiKeyProvider);
  final client = ChapterRemoteOperations(
    client: restClient,
    apiKey: apiKey ?? '',
  );

  return ChaptersRepository(db, client);
}

class ChaptersRepository {
  final AppDatabase _db;
  final ChapterRemoteOperations _client;

  ChaptersRepository(this._db, this._client);

  Stream<ChapterModel> watchChapter({
    required int chapterId,
  }) {
    return _db.chaptersDao
        .watchChapter(chapterId)
        .map(ChapterModel.fromDatabaseModel);
  }

  Stream<ImageModel> watchChapterCover(int chapterId) {
    refreshChapterCover(chapterId);
    return _db.chaptersDao
        .watchChapterCover(chapterId: chapterId)
        .map((cover) => ImageModel(data: cover.image));
  }

  Future<void> refreshChapter({
    required int seriesId,
    required int chapterId,
  }) async {
    try {
      final chapter = await _client.getChapter(chapterId);
      await _db.chaptersDao.upsertChapter(
        chapter.copyWith(seriesId: Value(seriesId)),
      );
    } catch (e) {
      log.e(e);
    }
  }

  Future<void> refreshChapterCover(int chapterId) async {
    try {
      final chapterCover = await _client.getChapterCover(chapterId);
      await _db.chaptersDao.upsertChapterCover(chapterCover);
    } catch (e) {
      log.e(e);
    }
  }
}

class ChapterRemoteOperations {
  final Openapi _client;
  final String _apiKey;

  const ChapterRemoteOperations({
    required Openapi client,
    required String apiKey,
  }) : _client = client,
       _apiKey = apiKey;

  Future<ChaptersCompanion> getChapter(int chapterId) async {
    final res = await _client.apiChapterGet(chapterId: chapterId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load chapter: ${res.error}');
    }

    return mapChapterCompanion(res.body!);
  }

  Future<ChapterCoversCompanion> getChapterCover(int chapterId) async {
    final res = await _client.apiImageChapterCoverGet(
      chapterId: chapterId,
      apiKey: _apiKey,
    );

    if (!res.isSuccessful) {
      throw Exception('Failed to load chapter cover: ${res.error}');
    }

    return ChapterCoversCompanion(
      chapterId: Value(chapterId),
      image: Value(res.bodyBytes),
    );
  }

  static ChaptersCompanion mapChapterCompanion(ChapterDto dto) {
    return ChaptersCompanion(
      id: Value(dto.id!),
      volumeId: Value(dto.volumeId!),
      title: Value(dto.titleName),
      description: Value(dto.summary),
      summary: Value(dto.summary),
      isbn: Value(dto.isbn),
      format: Value(
        dto.format != null ? Format.fromDtoFormat(dto.format!) : .unknown,
      ),
      language: Value(dto.language),
      sortOrder: Value(dto.sortOrder ?? 0.0),
      pages: Value(dto.pages!),
      pagesRead: Value(dto.pagesRead!),
      wordCount: Value(dto.wordCount ?? 0),
      avgHoursToRead: Value(dto.avgHoursToRead ?? 0.0),
      primaryColor: Value(dto.primaryColor),
      secondaryColor: Value(dto.secondaryColor),
      totalReads: Value(dto.totalReads ?? 0),
      isSpecial: Value(dto.isSpecial ?? false),
      releaseDate: Value(dto.releaseDate ?? DateTime.now()),
      created: Value(dto.createdUtc ?? DateTime.now()),
      lastModified: Value(DateTime.now()),
      lastReadingProgress: Value(dto.lastReadingProgressUtc ?? DateTime.now()),
    );
  }
}
