import 'dart:convert';

import 'package:fluvita/riverpod/api/client.dart';
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
  return doc;
}

@freezed
sealed class BookPageElementsResult with _$BookPageElementsResult {
  const factory BookPageElementsResult({
    required Element wrapper,
    required Map<String, Map<String, String>> styles,
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

  final styles = body.getElementsByTagName('style').first;
  final stylesMap = _parseStyles(styles.innerHtml);

  // For pages with sections, return section children as elements as it is most probably the page container
  final section = body.getElementsByTagName('section').firstOrNull;
  if (section != null) {
    return BookPageElementsResult(
      wrapper: section,
      styles: stylesMap,
      elements: section.children,
    );
  }

  // Kavita wraps pages into one div with the scoped styles in it. Finding the styles thus should generally puts us at a
  // sibling of the content
  final parent = styles.parent;
  final contentSiblings =
      parent?.children.where((e) => e != styles).toList() ?? [];

  // Having the siblings, if we have multiople, we assume there is no further wrapper
  if (parent != null && contentSiblings.length > 1) {
    return BookPageElementsResult(
      wrapper: body,
      styles: stylesMap,
      elements: parent.children.where((e) => e != styles).toList(),
    );
  }

  final container = contentSiblings.firstOrNull;

  // If there is only one tag, that is probably a container similar to a section.
  if (container != null && container.children.isNotEmpty) {
    // For pages without paragraphs (image-only, etc.),
    // return as single element to preserve structure and prevent rendering issues
    return BookPageElementsResult(
      wrapper: container,
      styles: stylesMap,
      elements: container.children,
    );
  }

  // Fall back returning body with no elements causing the reader to render as is
  return BookPageElementsResult(
    wrapper: body,
    styles: stylesMap,
    elements: [],
  );
}

Map<String, Map<String, String>> _parseStyles(String css) {
  final Map<String, Map<String, String>> stylesMap = {};
  final RegExp ruleRegExp = RegExp(r'([^{]+)\{([^}]+)\}');
  final RegExp propRegExp = RegExp(r'([^:]+):([^;]+);?');

  for (final ruleMatch in ruleRegExp.allMatches(css)) {
    final selector = ruleMatch.group(1)!.trim();
    final properties = ruleMatch.group(2)!;
    final Map<String, String> propsMap = {};

    for (final propMatch in propRegExp.allMatches(properties)) {
      final prop = propMatch.group(1)!.trim();
      final value = propMatch.group(2)!.trim();
      propsMap[prop] = value;
    }

    stylesMap[selector] = propsMap;
  }
  return stylesMap;
}
