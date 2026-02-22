import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/mapping/tables/reading_progress_data.dart';
import 'package:fluvita/models/chapter_model.dart';
import 'package:fluvita/models/progress_model.dart';
import 'package:fluvita/riverpod/providers/client.dart';
import 'package:fluvita/riverpod/repository/database.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

  Future<ChapterModel> getContinuePoint({required int seriesId}) async {
    final chapter = await _db.readerDao.getContinuePoint(seriesId: seriesId);
    return ChapterModel.fromDatabaseModel(chapter);
  }

  Stream<double> watchContinuePointProgress({required int seriesId}) {
    return _db.readerDao.watchContinuePointProgress(seriesId: seriesId);
  }

  Future<ProgressModel?> getProgress(int chapterId) async {
    final progress = await _db.readerDao.getProgress(chapterId);

    if (progress == null) {
      return null;
    }

    return ProgressModel.fromDatabaseModel(progress);
  }

  Future<void> refreshProgress(int chapterId) async {
    final entry = await _client.getProgress(chapterId);
    await _db.readerDao.mergeProgress(entry);
  }

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

  Future<void> saveProgress(ProgressModel progress) async {
    await _db.readerDao.upsertProgress(
      ReadingProgressCompanion(
        chapterId: Value(progress.chapterId),
        volumeId: Value(progress.volumeId),
        seriesId: Value(progress.seriesId),
        libraryId: Value(progress.libraryId),
        pagesRead: Value(progress.pageNum),
        bookScrollId: Value(progress.bookScrollId),
        lastModified: Value(DateTime.timestamp()),
        dirty: const Value(true),
      ),
    );
  }

  Future<void> refreshContinuePointsAndProgress() async {
    final series = await _db.seriesDao.allSeries().get();
    final updates = await Future.wait(
      series.map((s) async {
        final continuePoint = await _client.getContinuePoint(s.id);
        final progress = await _client.getProgress(
          continuePoint,
        );

        return (continuePoint: continuePoint, progress: progress);
      }),
    );

    await _db.readerDao.upsertCleanProgressBatch(
      updates.map((u) => u.progress),
    );
  }

  /// Synchronize all dirty progress entries by sending them to the backend and refetching the updated state.
  Future<void> mergeProgress() async {
    final dirty = await _db.readerDao.getDirtyProgress();
    log.d('processing ${dirty.length} progress entries');

    final updatedProgress = <ReadingProgressCompanion>[];
    for (final d in dirty) {
      await _client.sendProgress(d);
      updatedProgress.add(await _client.getProgress(d.chapterId));
    }
    await _db.readerDao.upsertProgressBatch(updatedProgress);
  }

  Future<void> markSeriesRead(int seriesId) async {
    await _db.readerDao.markSeriesRead(seriesId, isRead: true);
  }

  Future<void> markSeriesUnread(int seriesId) async {
    await _db.readerDao.markSeriesRead(seriesId, isRead: false);
  }

  Future<void> markVolumeRead(int seriesId, int volumeId) async {
    await _db.readerDao.markVolumeRead(seriesId, volumeId, isRead: true);
  }

  Future<void> markVolumeUnread(int seriesId, int volumeId) async {
    await _db.readerDao.markVolumeRead(seriesId, volumeId, isRead: false);
  }

  Future<void> markChapterRead(int seriesId, int chapterId) async {
    await _db.readerDao.markChapterRead(chapterId, isRead: true);
  }

  Future<void> markChapterUnread(int seriesId, int chapterId) async {
    await _db.readerDao.markChapterRead(chapterId, isRead: false);
  }
}

class ReaderRemoteOperations {
  final Openapi _client;

  const ReaderRemoteOperations({required Openapi client}) : _client = client;

  Future<int> getContinuePoint(int seriesId) async {
    final res = await _client.apiReaderContinuePointGet(seriesId: seriesId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load continue point: ${res.error}');
    }

    final chapterDto = res.body!;
    return chapterDto.id!;
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
      pagesRead: Value(dto.pageNum),
      bookScrollId: Value(dto.bookScrollId),
      lastModified: Value.absentIfNull(dto.lastModifiedUtc),
    );
  }

  Future<void> sendProgress(ReadingProgressData progress) async {
    await _client.apiReaderProgressPost(body: progress.toProgressDto());
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
