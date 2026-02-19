import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/models/chapter_model.dart';
import 'package:fluvita/models/progress_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/repository/database.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stream_transform/stream_transform.dart';

part 'reader_repository.g.dart';

@riverpod
ReaderRepository readerRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final restClient = ref.watch(restClientProvider);
  final client = ReaderRemoteOperations(client: restClient);
  return ReaderRepository(db, client);
}

class ReaderRepository {
  final AppDatabase _db;
  final ReaderRemoteOperations _client;

  ReaderRepository(this._db, this._client);

  // ── Continue point ───────────────────────────────────────────────────────

  Stream<ChapterModel> watchContinuePoint({required int seriesId}) {
    refreshContinuePoint(seriesId);
    return _db.readerDao
        .continuePoint(seriesId: seriesId)
        .map(ChapterModel.fromDatabaseModel);
  }

  Future<void> refreshContinuePoint(int seriesId) async {
    try {
      final continuePoint = await _client.getContinuePoint(seriesId);
      await _db.readerDao.upsertContinuePoint(continuePoint);
    } catch (e) {
      log.e(e);
    }
  }

  // ── Reading progress ─────────────────────────────────────────────────────

  Stream<ProgressModel> watchProgress(int chapterId) {
    refreshProgress(chapterId);
    return _db.readerDao
        .watchProgress(chapterId)
        .whereNotNull()
        .map(ProgressModel.fromDatabaseModel);
  }

  Future<void> refreshProgress(int chapterId) async {
    try {
      final entry = await _client.getProgress(chapterId);
      await _db.readerDao.upsertProgress(entry);
    } catch (e) {
      log.e(e);
    }
  }

  // ── Prev / next chapter (local DB query) ─────────────────────────────────

  Stream<int?> watchPrevChapterId({
    required int seriesId,
    int? volumeId,
    required int chapterId,
  }) {
    return _db.readerDao
        .watchPrevChapter(
          seriesId: seriesId,
          volumeId: volumeId,
          chapterId: chapterId,
        )
        .map((chapter) => chapter?.id);
  }

  Stream<int?> watchNextChapterId({
    required int seriesId,
    int? volumeId,
    required int chapterId,
  }) {
    return _db.readerDao
        .watchNextChapter(
          seriesId: seriesId,
          volumeId: volumeId,
          chapterId: chapterId,
        )
        .map((chapter) => chapter?.id);
  }

  // ── Mark read ────────────────────────────────────────────────────────────

  Future<void> markSeriesRead(int seriesId) async {
    await _db.readerDao.markSeriesRead(seriesId, isRead: true);
    try {
      await _client.markSeriesRead(seriesId);
    } catch (e) {
      log.e(e);
      await _db.readerDao.markSeriesRead(seriesId, isRead: false);
    }
  }

  Future<void> markSeriesUnread(int seriesId) async {
    await _db.readerDao.markSeriesRead(seriesId, isRead: false);
    try {
      await _client.markSeriesUnread(seriesId);
    } catch (e) {
      log.e(e);
      await _db.readerDao.markSeriesRead(seriesId, isRead: true);
    }
  }

  Future<void> markVolumeRead(int seriesId, int volumeId) async {
    await _db.readerDao.markVolumeRead(seriesId, volumeId, isRead: true);
    try {
      await _client.markVolumeRead(seriesId, volumeId);
    } catch (e) {
      log.e(e);
      await _db.readerDao.markVolumeRead(seriesId, volumeId, isRead: false);
    }
  }

  Future<void> markVolumeUnread(int seriesId, int volumeId) async {
    await _db.readerDao.markVolumeRead(seriesId, volumeId, isRead: false);
    try {
      await _client.markVolumeUnread(seriesId, volumeId);
    } catch (e) {
      log.e(e);
      await _db.readerDao.markVolumeRead(seriesId, volumeId, isRead: true);
    }
  }

  Future<void> markChapterRead(int seriesId, int chapterId) async {
    await _db.readerDao.markChapterRead(chapterId, isRead: true);
    try {
      await _client.markChaptersRead(seriesId, [chapterId]);
    } catch (e) {
      log.e(e);
      await _db.readerDao.markChapterRead(chapterId, isRead: false);
    }
  }

  Future<void> markChapterUnread(int seriesId, int chapterId) async {
    await _db.readerDao.markChapterRead(chapterId, isRead: false);
    try {
      await _client.markChaptersUnread(seriesId, [chapterId]);
    } catch (e) {
      log.e(e);
      await _db.readerDao.markChapterRead(chapterId, isRead: true);
    }
  }
}

class ReaderRemoteOperations {
  final Openapi _client;

  const ReaderRemoteOperations({required Openapi client}) : _client = client;

  Future<ContinuePointsCompanion> getContinuePoint(int seriesId) async {
    final res = await _client.apiReaderContinuePointGet(seriesId: seriesId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load continue point: ${res.error}');
    }

    final chapterDto = res.body!;
    return ContinuePointsCompanion(
      seriesId: Value(seriesId),
      chapterId: Value(chapterDto.id!),
    );
  }

  Future<ReadingProgressCompanion> getProgress(int chapterId) async {
    final res = await _client.apiReaderGetProgressGet(chapterId: chapterId);
    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load progress: ${res.error}');
    }
    final dto = res.body!;
    return ReadingProgressCompanion(
      chapterId: Value(chapterId),
      volumeId: Value(dto.volumeId),
      seriesId: Value(dto.seriesId),
      libraryId: Value(dto.libraryId),
      pageNum: Value(dto.pageNum),
      bookScrollId: Value(dto.bookScrollId),
      lastModified: Value.absentIfNull(dto.lastModifiedUtc),
    );
  }

  Future<void> markSeriesRead(int seriesId) async {
    final res = await _client.apiReaderMarkReadPost(
      body: MarkReadDto(seriesId: seriesId),
    );
    if (!res.isSuccessful) {
      throw Exception('Failed to mark series as read: ${res.error}');
    }
  }

  Future<void> markSeriesUnread(int seriesId) async {
    final res = await _client.apiReaderMarkUnreadPost(
      body: MarkReadDto(seriesId: seriesId),
    );
    if (!res.isSuccessful) {
      throw Exception('Failed to mark series as unread: ${res.error}');
    }
  }

  Future<void> markVolumeRead(int seriesId, int volumeId) async {
    final res = await _client.apiReaderMarkVolumeReadPost(
      body: MarkVolumeReadDto(seriesId: seriesId, volumeId: volumeId),
    );
    if (!res.isSuccessful) {
      throw Exception('Failed to mark volume as read: ${res.error}');
    }
  }

  Future<void> markVolumeUnread(int seriesId, int volumeId) async {
    final res = await _client.apiReaderMarkVolumeUnreadPost(
      body: MarkVolumeReadDto(seriesId: seriesId, volumeId: volumeId),
    );
    if (!res.isSuccessful) {
      throw Exception('Failed to mark volume as unread: ${res.error}');
    }
  }

  Future<void> markChaptersRead(int seriesId, List<int> chapterIds) async {
    final res = await _client.apiReaderMarkMultipleReadPost(
      body: MarkVolumesReadDto(seriesId: seriesId, chapterIds: chapterIds),
    );
    if (!res.isSuccessful) {
      throw Exception('Failed to mark chapter as read: ${res.error}');
    }
  }

  Future<void> markChaptersUnread(int seriesId, List<int> chapterIds) async {
    final res = await _client.apiReaderMarkMultipleUnreadPost(
      body: MarkVolumesReadDto(seriesId: seriesId, chapterIds: chapterIds),
    );
    if (!res.isSuccessful) {
      throw Exception('Failed to mark chapter as unread: ${res.error}');
    }
  }
}
