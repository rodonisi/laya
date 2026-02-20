import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/mapping/dto/chapter_dto_mappings.dart';
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

  Stream<int> watchPagesRead({required int chapterId}) {
    return _db.chaptersDao
        .watchPagesRead(chapterId: chapterId)
        .map((n) => n ?? 0);
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

    return res.body!.toChapterCompanion();
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
}
