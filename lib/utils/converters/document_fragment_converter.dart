import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:html/dom.dart';

class DocumentFragmentConverter
    implements JsonConverter<DocumentFragment, String> {
  const DocumentFragmentConverter();

  @override
  DocumentFragment fromJson(String json) {
    return DocumentFragment.html(json);
  }

  @override
  String toJson(DocumentFragment fragment) {
    return fragment.outerHtml;
  }
}
