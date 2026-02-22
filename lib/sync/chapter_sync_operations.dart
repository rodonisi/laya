import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/mapping/dto/chapter_dto_mappings.dart';

class ChapterSyncOperations {
  final Openapi _client;
  final String _apiKey;

  const ChapterSyncOperations({
    required Openapi client,
    required String apiKey,
  }) : _client = client,
       _apiKey = apiKey;

  /// Fetch chapter [chapterId]
  Future<ChaptersCompanion> getChapter(int chapterId) async {
    final res = await _client.apiChapterGet(chapterId: chapterId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load chapter: ${res.error}');
    }

    return res.body!.toChapterCompanion();
  }

  /// Fetch chapter cover for [chapterId]
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
