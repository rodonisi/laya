import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/models/page_content.dart';
import 'package:fluvita/utils/extensions/element.dart';
import 'package:fluvita/utils/html_constants.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

class BookSyncOperations {
  final Openapi _client;
  final String _apiKey;

  const BookSyncOperations({required Openapi client, required String apiKey})
    : _client = client,
      _apiKey = apiKey;

  /// Get the book chapter to page mapping (aka TOC) for [chapterId].
  Future<Iterable<BookChaptersTableCompanion>> getBookChapters(
    int chapterId,
  ) async {
    final res = await _client.apiBookChapterIdChaptersGet(
      chapterId: chapterId,
    );
    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load book chapters: ${res.error}');
    }
    return _flattenChapters(chapterId, res.body!, null);
  }

  /// Get image [page] for [chapterId]
  Future<Uint8List> getImagePage({
    required int chapterId,
    required int page,
  }) async {
    final res = await _client.apiReaderImageGet(
      chapterId: chapterId,
      page: page,
      apiKey: _apiKey,
    );

    if (!res.isSuccessful) {
      throw Exception('Failed to load reader image: ${res.error}');
    }

    return res.bodyBytes;
  }

  /// Get preprocessed epub page [page] for [chapterId]
  Future<PageContent> getPageContent({
    required int chapterId,
    required int page,
  }) async {
    final frag = await _getPreprocessedPage(chapterId: chapterId, page: page);
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

  static Iterable<BookChaptersTableCompanion> _flattenChapters(
    int chapterId,
    List<BookChapterItem> items,
    int? parentPage,
  ) sync* {
    for (final item in items) {
      yield BookChaptersTableCompanion(
        chapterId: Value(chapterId),
        title: Value(item.title!),
        page: Value(item.page!),
        parentPage: Value(parentPage),
      );
      if (item.children != null && item.children!.isNotEmpty) {
        yield* _flattenChapters(chapterId, item.children!, item.page!);
      }
    }
  }

  Future<String> _getRawBookPage({
    required int chapterId,
    required int page,
  }) async {
    final res = await _client.apiBookChapterIdBookPageGet(
      chapterId: chapterId,
      page: page,
    );

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load book page: ${res.error}');
    }

    return res.body!;
  }

  Future<DocumentFragment> _getPreprocessedPage({
    required int chapterId,
    required int page,
  }) async {
    Future<void> walk(Node node) async {
      for (var n in node.children) {
        n.attributes[HtmlConstants.scrollIdAttribute] = n.scrollId;

        if (n.localName == 'img') {
          final src = 'https:${n.attributes['src']}';
          if (src.isNotEmpty) {
            final imageData = await _fetchImageData(src);
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
          final imageData = await _fetchImageData(src);
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

    final html = await _getRawBookPage(chapterId: chapterId, page: page);
    final doc = parseFragment(html);
    for (var node in doc.nodes) {
      await walk(node);
    }

    return doc;
  }

  Future<({Uint8List bytes, String mimeType})?> _fetchImageData(
    String imageUrl,
  ) async {
    try {
      final res = await _client.client.get(
        Uri.parse(imageUrl),
        headers: {'Accept': 'image/*'},
      );

      if (res.isSuccessful && res.bodyBytes.isNotEmpty) {
        final mimeType = res.headers['content-type'] ?? 'image/png';
        return (bytes: res.bodyBytes, mimeType: mimeType);
      }
    } catch (e) {
      log.e('failed to fetch page image', error: e);
    }

    return null;
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
}
