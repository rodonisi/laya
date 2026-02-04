import 'dart:convert';
import 'dart:typed_data';

import 'package:fluvita/models/book_chapter_model.dart';
import 'package:fluvita/models/book_info_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/utils/extensions/element.dart';
import 'package:fluvita/utils/html_constants.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'book.freezed.dart';
part 'book.g.dart';

@riverpod
Future<BookInfoModel> bookInfo(Ref ref, {required int chapterId}) async {
  final client = ref.watch(restClientProvider);
  final res = await client.apiBookChapterIdBookInfoGet(chapterId: chapterId);

  if (!res.isSuccessful || res.body == null) {
    throw Exception('Failed to load book info: ${res.error}');
  }

  return BookInfoModel.fromBookInfoDto(res.body!);
}

@riverpod
Future<List<BookChapterModel>> bookChapters(
  Ref ref, {
  required int chapterId,
}) async {
  final client = ref.watch(restClientProvider);
  final res = await client.apiBookChapterIdChaptersGet(chapterId: chapterId);

  if (!res.isSuccessful || res.body == null) {
    throw Exception('Failed to load book chapters: ${res.error}');
  }

  return res.body?.map(BookChapterModel.fromChapterItemDto).toList() ?? [];
}

@riverpod
Future<String> bookPage(Ref ref, {required int chapterId, int? page}) async {
  final client = ref.watch(restClientProvider);
  final res = await client.apiBookChapterIdBookPageGet(
    chapterId: chapterId,
    page: page,
  );

  if (!res.isSuccessful || res.body == null) {
    throw Exception('Failed to load book page: ${res.error}');
  }

  return res.body!;
}

@riverpod
Future<DocumentFragment> preprocessedHtml(
  Ref ref, {
  required int chapterId,
  int? page,
  String? resumeScrollId,
}) async {
  final html = await ref.watch(
    bookPageProvider(chapterId: chapterId, page: page).future,
  );

  Future<void> walk(Node node) async {
    for (var n in node.children) {
      n.attributes[HtmlConstants.scrollIdAttribute] = n.scrollId;

      if (n.localName == 'img') {
        final src = 'https:${n.attributes['src']}';
        if (src.isNotEmpty) {
          final imageData = await _fetchImageData(ref, src);
          if (imageData != null) {
            final base64img = base64Encode(imageData.bytes);
            n.attributes['src'] =
                'data:${imageData.mimeType};base64,$base64img';
          }
        }
      }

      if (n.localName == 'image') {
        final attr = n.attributes.entries.where((entry) {
          final key = entry.key;
          return key is AttributeName && key.name == 'href';
        }).first;

        final src = 'https:${attr.value}';
        final imageData = await _fetchImageData(ref, src);
        if (imageData != null) {
          final base64img = base64Encode(
            imageData.bytes,
          ).replaceAll(RegExp(r'\s+'), '');

          // Replace <svg><image></image></svg> with <img> with embedded base64
          final imgTag = Element.tag('img');
          imgTag.attributes['src'] =
              'data:${imageData.mimeType};base64,$base64img';

          // Copy over width/height if present
          if (n.attributes['width'] != null) {
            imgTag.attributes['width'] = n.attributes['width']!;
          }
          if (n.attributes['height'] != null) {
            imgTag.attributes['height'] = n.attributes['height']!;
          }

          final svgParent = n.parent;
          if (svgParent != null && svgParent.localName == 'svg') {
            svgParent.replaceWith(imgTag);
          } else {
            n.replaceWith(imgTag);
          }
        }
      }

      await walk(n);
    }
  }

  final doc = parseFragment(html);
  for (var node in doc.nodes) {
    await walk(node);
  }

  return doc;
}

@freezed
sealed class PageContent with _$PageContent {
  const factory PageContent({
    required DocumentFragment root,
    required Map<String, Map<String, String>> styles,
  }) = _PageContent;
}

@riverpod
Future<PageContent> preprocessedPage(
  Ref ref, {
  required int chapterId,
  int? page,
  String? resumeScrollId,
}) async {
  final frag = await ref.watch(
    preprocessedHtmlProvider(
      chapterId: chapterId,
      page: page,
      resumeScrollId: resumeScrollId,
    ).future,
  );

  final styles = <String, Map<String, String>>{};

  final stylesElement = frag.querySelector('style');
  if (stylesElement != null) {
    styles.addAll(_parseStyles(stylesElement.innerHtml));
    stylesElement.remove();
  }

  styles['.${HtmlConstants.resumeParagraphClass}'] = {
    'background-color': 'rgba(255,255,0,0.2);',
  };

  styles['a'] = {'text-decoration': 'none'};

  return PageContent(root: frag, styles: styles);
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

Future<({Uint8List bytes, String mimeType})?> _fetchImageData(
  Ref ref,
  String imageUrl,
) async {
  try {
    final chopperClient = ref.watch(authenticatedClientProvider);

    final res = await chopperClient.get(
      Uri.parse(imageUrl),
      headers: {'Accept': 'image/*'},
    );

    if (res.isSuccessful && res.bodyBytes.isNotEmpty) {
      final mimeType = res.headers['content-type'] ?? 'image/png';
      return (bytes: res.bodyBytes, mimeType: mimeType);
    }
  } catch (e) {
    // Log error but don't fail the entire page load
  }

  return null;
}
