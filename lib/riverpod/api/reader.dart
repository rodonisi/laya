import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fluvita/api/models/progress_dto.dart';
import 'package:fluvita/models/chapter_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reader.g.dart';

@riverpod
Future<ChapterModel> continuePoint(Ref ref, {required int seriesId}) async {
  final client = ref.watch(restClientProvider).reader;
  final res = await client.getApiReaderContinuePoint(seriesId: seriesId);

  return ChapterModel.fromChapterDto(res);
}

@riverpod
Future<ProgressDto> bookProgress(Ref ref, {required int chapterId}) async {
  final client = ref.watch(restClientProvider).reader;
  return await client.getApiReaderGetProgress(chapterId: chapterId);
}

@riverpod
Future<Uint8List> readerImage(
  Ref ref, {
  required int chapterId,
  required int page,
}) async {
  final dio = ref.watch(authenticatedDioProvider);
  final key = ref.watch(apiKeyProvider);

  final res = await dio.get(
    '/api/reader/image',
    queryParameters: {
      'chapterId': chapterId,
      'page': page,
      'apiKey': key,
    },
    options: Options(
      responseType: .bytes,
      headers: {
        'Accept': 'image/*',
      },
    ),
  );

  if (res.statusCode != 200) {
    throw Exception(
      'failed to load image: ${res.statusCode} ${res.statusMessage}',
    );
  }

  return res.data;
}

@riverpod
Future<int?> prevChapter(
  Ref ref, {
  int? seriesId,
  int? volumeId,
  int? chapterId,
}) async {
  final client = ref.watch(restClientProvider).reader;
  final chapter = await client.getApiReaderPrevChapter(
    seriesId: seriesId,
    volumeId: volumeId,
    currentChapterId: chapterId,
  );

  return chapter >= 0 ? chapter : null;
}

@riverpod
Future<int?> nextChapter(
  Ref ref, {
  int? seriesId,
  int? volumeId,
  int? chapterId,
}) async {
  final client = ref.watch(restClientProvider).reader;
  final chapter = await client.getApiReaderNextChapter(
    seriesId: seriesId,
    volumeId: volumeId,
    currentChapterId: chapterId,
  );

  return chapter >= 0 ? chapter : null;
}
