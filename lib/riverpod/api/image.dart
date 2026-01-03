import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:laya/riverpod/api/auth.dart';
import 'package:laya/riverpod/api/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image.g.dart';

@riverpod
Future<Uint8List> seriesCover(Ref ref, {required int seriesId}) async {
  final dio = ref.watch(authenticatedDioProvider);
  final key = ref.watch(currentUserProvider).value?.apiKey;

  final res = await dio.get(
    '/api/Image/series-cover',
    queryParameters: {
      'seriesId': seriesId,
      'apiKey': key,
    },
    options: Options(
      responseType: .bytes,
      headers: {
        'Accept': 'image/*',
      },
    ),
  );

  return res.data;
}

@riverpod
Future<Uint8List> chapterCover(Ref ref, {required int chapterId}) async {
  final dio = ref.watch(authenticatedDioProvider);
  final key = ref.watch(currentUserProvider).value?.apiKey;

  final res = await dio.get(
    '/api/Image/chapter-cover',
    queryParameters: {
      'chapterId': chapterId,
      'apiKey': key,
    },
    options: Options(
      responseType: .bytes,
      headers: {
        'Accept': 'image/*',
      },
    ),
  );

  return res.data;
}

@riverpod
Future<Uint8List> volumeCover(Ref ref, {required int volumeId}) async {
  final dio = ref.watch(authenticatedDioProvider);
  final key = ref.watch(currentUserProvider).value?.apiKey;

  final res = await dio.get(
    '/api/Image/volume-cover',
    queryParameters: {
      'volumeId': volumeId,
      'apiKey': key,
    },
    options: Options(
      responseType: .bytes,
      headers: {
        'Accept': 'image/*',
      },
    ),
  );

  return res.data;
}

@riverpod
Future<Uint8List> libraryCover(Ref ref, {required int libraryId}) async {
  final dio = ref.watch(authenticatedDioProvider);
  final key = ref.watch(currentUserProvider).value?.apiKey;

  final res = await dio.get(
    '/api/Image/library-cover',
    queryParameters: {
      'libraryId': libraryId,
      'apiKey': key,
    },
    options: Options(
      responseType: .bytes,
      headers: {
        'Accept': 'image/*',
      },
    ),
  );

  return res.data;
}
