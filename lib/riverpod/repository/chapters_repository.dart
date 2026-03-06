import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/models/chapter_model.dart';
import 'package:fluvita/models/image_model.dart';
import 'package:fluvita/riverpod/providers/client.dart';
import 'package:fluvita/riverpod/providers/settings/settings.dart';
import 'package:fluvita/riverpod/repository/database.dart';
import 'package:fluvita/sync/chapter_sync_operations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chapters_repository.g.dart';

@riverpod
ChaptersRepository chaptersRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final restClient = ref.watch(restClientProvider);
  final apiKey = ref.watch(apiKeyProvider);
  final client = ChapterSyncOperations(
    client: restClient,
    apiKey: apiKey ?? '',
  );

  return ChaptersRepository(db, client);
}

class ChaptersRepository {
  final AppDatabase _db;
  final ChapterSyncOperations _client;

  ChaptersRepository(this._db, this._client);

  /// Watch [chapterId]
  Stream<ChapterModel> watchChapter({
    required int chapterId,
  }) {
    return _db.chaptersDao
        .watchChapter(chapterId)
        .map(ChapterModel.fromDatabaseModel);
  }

  /// Watch the number of pages read for [chapterId]
  Stream<int> watchPagesRead({required int chapterId}) {
    return _db.chaptersDao
        .watchPagesRead(chapterId: chapterId)
        .map((n) => n ?? 0);
  }

  /// Watch the chapter cover for [chapterId]
  Stream<ImageModel?> watchChapterCover(int chapterId) {
    return _db.chaptersDao
        .watchChapterCover(chapterId: chapterId)
        .map((cover) => cover != null ? ImageModel(data: cover.image) : null);
  }

  /// Fetch all missing chapter covers
  Future<void> fetchMissingCovers() async {
    final missing = await _db.chaptersDao.getMissingCovers();
    for (final id in missing) {
      final chapterCover = await _client.getChapterCover(id);
      await _db.chaptersDao.upsertChapterCover(chapterCover);
    }
  }
}
