import 'dart:typed_data';

import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image.g.dart';

@riverpod
Future<Uint8List> seriesCover(Ref ref, {required int seriesId}) async {
  final client = ref.watch(restClientProvider);
  final key = ref.watch(apiKeyProvider);

  final res = await client.apiImageSeriesCoverGet(
    seriesId: seriesId,
    apiKey: key,
  );

  if (!res.isSuccessful) {
    throw Exception('Failed to load series cover: ${res.error}');
  }

  return res.bodyBytes;
}

@riverpod
Future<Uint8List> chapterCover(Ref ref, {required int chapterId}) async {
  final client = ref.watch(restClientProvider);
  final key = ref.watch(apiKeyProvider);

  final res = await client.apiImageChapterCoverGet(
    chapterId: chapterId,
    apiKey: key,
  );

  if (!res.isSuccessful) {
    throw Exception('Failed to load chapter cover: ${res.error}');
  }

  return res.bodyBytes;
}

@riverpod
Future<Uint8List> volumeCover(Ref ref, {required int volumeId}) async {
  final client = ref.watch(restClientProvider);
  final key = ref.watch(apiKeyProvider);

  final res = await client.apiImageVolumeCoverGet(
    volumeId: volumeId,
    apiKey: key,
  );

  if (!res.isSuccessful) {
    throw Exception('Failed to load volume cover: ${res.error}');
  }

  return res.bodyBytes;
}

@riverpod
Future<Uint8List> libraryCover(Ref ref, {required int libraryId}) async {
  final client = ref.watch(restClientProvider);
  final key = ref.watch(apiKeyProvider);

  final res = await client.apiImageLibraryCoverGet(
    libraryId: libraryId,
    apiKey: key,
  );

  if (!res.isSuccessful) {
    throw Exception('Failed to load library cover: ${res.error}');
  }

  return res.bodyBytes;
}
