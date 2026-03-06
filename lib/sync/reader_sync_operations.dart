import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/mapping/dto/progress_dto_mappings.dart';
import 'package:fluvita/mapping/tables/reading_progress_data.dart';

class ReaderSyncOperations {
  final Openapi _client;

  const ReaderSyncOperations({required Openapi client}) : _client = client;

  /// Fetch continue point for [seriesId]
  Future<int> getContinuePoint(int seriesId) async {
    final res = await _client.apiReaderContinuePointGet(seriesId: seriesId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load continue point: ${res.error}');
    }

    final chapterDto = res.body!;
    return chapterDto.id!;
  }

  /// Fetch progress for [chapterId]
  Future<ReadingProgressCompanion> getProgress(int chapterId) async {
    final res = await _client.apiReaderGetProgressGet(chapterId: chapterId);
    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load progress: ${res.error}');
    }
    final dto = res.body!;
    return dto.toReadingProgressCompanion();
  }

  /// Post local [ReadingProgressData]
  Future<void> sendProgress(ReadingProgressData progress) async {
    await _client.apiReaderProgressPost(body: progress.toProgressDto());
  }
}
