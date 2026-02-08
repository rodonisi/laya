import 'dart:typed_data';

import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/models/chapter_model.dart';
import 'package:fluvita/models/progress_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reader.g.dart';

@riverpod
Future<ChapterModel> continuePoint(Ref ref, {required int seriesId}) async {
  final client = ref.watch(restClientProvider);
  final res = await client.apiReaderContinuePointGet(seriesId: seriesId);

  if (!res.isSuccessful || res.body == null) {
    throw Exception('Failed to load continue point: ${res.error}');
  }

  return ChapterModel.fromChapterDto(res.body!);
}

@riverpod
Future<ProgressModel> bookProgress(Ref ref, {required int chapterId}) async {
  final client = ref.watch(restClientProvider);
  final res = await client.apiReaderGetProgressGet(chapterId: chapterId);

  if (!res.isSuccessful || res.body == null) {
    throw Exception('Failed to load progress: ${res.error}');
  }

  return ProgressModel.fromProgressDto(res.body!);
}

@riverpod
Future<Uint8List> readerImage(
  Ref ref, {
  required int chapterId,
  required int page,
}) async {
  final client = ref.watch(restClientProvider);
  final key = ref.watch(apiKeyProvider);

  final res = await client.apiReaderImageGet(
    chapterId: chapterId,
    page: page,
    apiKey: key,
  );

  if (!res.isSuccessful) {
    throw Exception('Failed to load image: ${res.error}');
  }

  return res.bodyBytes;
}

@riverpod
Future<int?> prevChapter(
  Ref ref, {
  int? seriesId,
  int? volumeId,
  int? chapterId,
}) async {
  final client = ref.watch(restClientProvider);
  final res = await client.apiReaderPrevChapterGet(
    seriesId: seriesId,
    volumeId: volumeId,
    currentChapterId: chapterId,
  );

  if (!res.isSuccessful || res.body == null) {
    return null;
  }

  final chapter = res.body!;
  return chapter >= 0 ? chapter : null;
}

@riverpod
Future<int?> nextChapter(
  Ref ref, {
  int? seriesId,
  int? volumeId,
  int? chapterId,
}) async {
  final client = ref.watch(restClientProvider);
  final res = await client.apiReaderNextChapterGet(
    seriesId: seriesId,
    volumeId: volumeId,
    currentChapterId: chapterId,
  );

  if (!res.isSuccessful || res.body == null) {
    return null;
  }

  final chapter = res.body!;
  return chapter >= 0 ? chapter : null;
}

@riverpod
class MarkSeriesRead extends _$MarkSeriesRead {
  @override
  Future<void> build({required int seriesId}) async {}

  Future<void> markRead() async {
    final client = ref.read(restClientProvider);
    final res = await client.apiReaderMarkReadPost(
      body: MarkReadDto(seriesId: seriesId),
    );

    if (!res.isSuccessful) {
      throw Exception('Failed to mark series as read: ${res.error}');
    }
  }

  Future<void> markUnread() async {
    final client = ref.read(restClientProvider);
    final res = await client.apiReaderMarkUnreadPost(
      body: MarkReadDto(seriesId: seriesId),
    );

    if (!res.isSuccessful) {
      throw Exception('Failed to mark series as unread: ${res.error}');
    }
  }
}

@riverpod
class MarkVolumeRead extends _$MarkVolumeRead {
  @override
  Future<void> build({required int seriesId, required int volumeId}) async {}

  Future<void> markRead() async {
    final client = ref.read(restClientProvider);
    final res = await client.apiReaderMarkVolumeReadPost(
      body: MarkVolumeReadDto(seriesId: seriesId, volumeId: volumeId),
    );

    if (!res.isSuccessful) {
      throw Exception('Failed to mark volume as read: ${res.error}');
    }
  }

  Future<void> markUnread() async {
    final client = ref.read(restClientProvider);
    final res = await client.apiReaderMarkVolumeUnreadPost(
      body: MarkVolumeReadDto(seriesId: seriesId, volumeId: volumeId),
    );

    if (!res.isSuccessful) {
      throw Exception('Failed to mark volume as unread: ${res.error}');
    }
  }
}

@riverpod
class MarkChapterRead extends _$MarkChapterRead {
  @override
  Future<void> build({required int seriesId, required int chapterId}) async {}

  Future<void> markRead() async {
    final client = ref.read(restClientProvider);
    final res = await client.apiReaderMarkMultipleReadPost(
      body: MarkVolumesReadDto(seriesId: seriesId, chapterIds: [chapterId]),
    );

    if (!res.isSuccessful) {
      throw Exception('Failed to mark chapter as read: ${res.error}');
    }
  }

  Future<void> markUnread() async {
    final client = ref.read(restClientProvider);
    final res = await client.apiReaderMarkMultipleUnreadPost(
      body: MarkVolumesReadDto(seriesId: seriesId, chapterIds: [chapterId]),
    );

    if (!res.isSuccessful) {
      throw Exception('Failed to mark chapter as unread: ${res.error}');
    }
  }
}
