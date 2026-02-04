import 'package:html/dom.dart';

extension DocumentFragmentExtensions on DocumentFragment {
  String? paragraphScrollId() {
    final p = querySelector('p');

    return p?.attributes['scroll-id'];
  }
}
