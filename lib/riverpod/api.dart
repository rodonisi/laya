import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:laya/api/export.dart';
import 'package:laya/riverpod/settings.dart';
import 'package:laya/utils/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api.g.dart';

@riverpod
class Jwt extends _$Jwt {
  @override
  String? build() {
    return ref.watch(currentUserProvider).value?.token;
  }
}

@riverpod
Dio dio(Ref ref) {
  final dio = Dio();
  final settings = ref.watch(settingsProvider).value;
  if (settings?.url != null) {
    dio.options.baseUrl = settings!.url!;
  }

  return dio;
}

@riverpod
Dio authenticatedDio(Ref ref) {
  final dio = Dio();
  final settings = ref.watch(settingsProvider).value;
  final jwt = ref.watch(jwtProvider);

  if (settings?.url != null) {
    dio.options.baseUrl = settings!.url!;
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (jwt != null && jwt.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $jwt';
        }
        handler.next(options);
      },
    ),
  );

  return dio;
}

@riverpod
RestClient restClient(Ref ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return RestClient(dio);
}

@riverpod
Future<UserDto?> currentUser(Ref ref) async {
  final settings = ref.watch(settingsProvider).value;
  final apiKey = settings?.apiKey;

  if (apiKey == null || apiKey.isEmpty) {
    return null;
  }

  final dio = ref.watch(dioProvider);
  final client = RestClient(dio).account;

  final user = await client.postApiAccountLogin(
    body: LoginDto(apiKey: apiKey, username: '', password: ''),
  );

  return user;
}

@riverpod
Future<List<LibraryDto>> libraries(Ref ref) async {
  final client = ref.watch(restClientProvider).library;
  return await client.getApiLibraryLibraries();
}

@riverpod
Future<List<SeriesDto>> series(Ref ref, int libraryId) async {
  final client = ref.watch(restClientProvider).series;
  return await client.postApiSeriesV2(
    body: FilterV2Dto(
      id: 0,
      combination: .value0,
      sortOptions: SortOptions(sortField: .value1, isAscending: false),
      limitTo: 20,
      statements: [
        FilterStatementDto(
          comparison: .value0,
          field: .value19,
          value: libraryId.toString(),
        ),
      ],
    ),
  );
}

@riverpod
Future<SeriesDetailDto> seriesDetail(Ref ref, int seriesID) async {
  final client = ref.watch(restClientProvider).series;
  return await client.getApiSeriesSeriesDetail(seriesId: seriesID);
}

@riverpod
Future<List<SeriesDto>> onDeck(Ref ref) async {
  final client = ref.watch(restClientProvider).series;
  return await client.postApiSeriesOnDeck();
}

@riverpod
Future<List<RecentlyAddedItemDto>> recentlyUpdated(Ref ref) async {
  final client = ref.watch(restClientProvider).series;
  return await client.postApiSeriesRecentlyUpdatedSeries();
}

@riverpod
Future<List<SeriesDto>> recentlyAdded(Ref ref) async {
  final client = ref.watch(restClientProvider).series;
  return await client.postApiSeriesRecentlyAddedV2();
}

@riverpod
Future<BookInfoDto> bookInfo(Ref ref, {required int chapterId}) async {
  final client = ref.watch(restClientProvider).book;
  return await client.getApiBookChapterIdBookInfo(chapterId: chapterId);
}

@riverpod
Future<ChapterDto> continuePoint(Ref ref, {required int seriesId}) async {
  final client = ref.watch(restClientProvider).reader;
  return await client.getApiReaderContinuePoint(seriesId: seriesId);
}

@riverpod
Future<ProgressDto> bookProgress(Ref ref, {required int chapterId}) async {
  final client = ref.watch(restClientProvider).reader;
  return await client.getApiReaderGetProgress(chapterId: chapterId);
}

@riverpod
Future<String> bookPage(Ref ref, {required int chapterId, int? page}) async {
  final dio = ref.watch(authenticatedDioProvider);
  final client = ref.watch(restClientProvider).book;
  final html = await client.getApiBookChapterIdBookPage(
    chapterId: chapterId,
    page: page,
  );

  final doc = parse(html);

  final imgElements = doc.getElementsByTagName('img');
  for (final img in imgElements) {
    final src = 'https:${img.attributes['src']}';
    if (src != null && src.isNotEmpty) {
      final res = await dio.get(
        src,
        options: Options(
          responseType: .bytes,
          headers: {
            'Accept': 'image/*',
          },
        ),
      );
      if (res.data != null) {
        final base64img = base64Encode(res.data);
        final mimeType = res.headers.value('content-type') ?? 'image/png';
        log.d(mimeType);

        img.attributes['src'] = 'data:$mimeType;base64,$base64img';
      }
    }
  }

  final imageElements = doc.getElementsByTagName('image');
  for (final img in imageElements) {
    final attr = img.attributes.entries.where((entry) {
      final key = entry.key;
      return key is AttributeName && key.name == 'href';
    }).first;

    final src = 'https:${attr.value}';
    final res = await dio.get(
      src,
      options: Options(
        responseType: .bytes,
        headers: {
          'Accept': 'image/*',
        },
      ),
    );
    if (res.data != null && res.statusCode == 200) {
      final base64img = base64Encode(res.data).replaceAll(RegExp(r'\s+'), '');
      final mimeType = res.headers.value('content-type') ?? 'image/png';

      // Replace <svg><image></image></svg> with <img> with embedded base64
      final imgTag = doc.createElement('img');
      imgTag.attributes['src'] = 'data:$mimeType;base64,$base64img';

      // Copy over width/height if present
      if (img.attributes['width'] != null) {
        imgTag.attributes['width'] = img.attributes['width']!;
      }
      if (img.attributes['height'] != null) {
        imgTag.attributes['height'] = img.attributes['height']!;
      }

      final svgParent = img.parent;
      if (svgParent != null && svgParent.localName == 'svg') {
        svgParent.replaceWith(imgTag);
      } else {
        img.replaceWith(imgTag);
      }
    }
  }

  return doc.outerHtml;
}

@riverpod
Future<String> page(Ref ref, {required int seriesId}) async {
  final chapter = await ref.watch(
    continuePointProvider(seriesId: seriesId).future,
  );

  final progress = await ref.watch(
    bookProgressProvider(chapterId: chapter.id).future,
  );

  return ref.watch(
    bookPageProvider(
      chapterId: progress.chapterId,
      page: progress.pageNum,
    ).future,
  );
}

@riverpod
Future<Uint8List> coverImage(Ref ref, {required int seriesId}) async {
  // final client = ref.watch(restClientProvider).image;
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
  // final res = await client.getApiImageSeriesCover(seriesId: seriesId);
  return res.data;
}
