import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluvita/api/models/book_info_dto.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'book.freezed.dart';
part 'book.g.dart';

@riverpod
Future<BookInfoDto> bookInfo(Ref ref, {required int chapterId}) async {
  final client = ref.watch(restClientProvider).book;
  return await client.getApiBookChapterIdBookInfo(chapterId: chapterId);
}

@riverpod
Future<Document> bookPage(Ref ref, {required int chapterId, int? page}) async {
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
    if (src.isNotEmpty) {
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

        // Ensure images have defined sizes for proper rendering
        if (!img.attributes.containsKey('width')) {
          img.attributes['width'] = '100%';
        }
        if (!img.attributes.containsKey('height')) {
          img.attributes['height'] = 'auto';
        }
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
  return doc;
}

@freezed
sealed class BookPageElementsResult with _$BookPageElementsResult {
  const factory BookPageElementsResult({
    required Element wrapper,
    required List<Element> elements,
  }) = _BookPageElementsResult;
}

@riverpod
Future<BookPageElementsResult> bookPageElements(
  Ref ref, {
  required int chapterId,
  int? page,
  int chunkSize = 5,
}) async {
  final doc = await ref.watch(
    bookPageProvider(
      chapterId: chapterId,
      page: page,
    ).future,
  );

  final body = doc.body;
  if (body == null) {
    throw Exception('No body found in HTML');
  }

  final paragraphs = body.getElementsByTagName('p');

  if (paragraphs.isEmpty) {
    // For pages without paragraphs (image-only, etc.),
    // return as single element to preserve structure and prevent rendering issues
    return BookPageElementsResult(wrapper: body, elements: []);
  }

  final contentParent = paragraphs.first.parent;

  final elements = contentParent?.children.toList();

  return BookPageElementsResult(
    wrapper: contentParent ?? body,
    elements: elements ?? [body],
  );
}
