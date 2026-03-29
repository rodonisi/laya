import 'package:html/dom.dart';

extension StringExtensions on String {
  bool isHtml() {
    final fragment = DocumentFragment.html(this);
    return fragment.children.isNotEmpty;
  }
}
