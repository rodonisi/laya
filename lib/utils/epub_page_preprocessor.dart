import 'package:csslib/parser.dart' as css;
import 'package:csslib/visitor.dart';
import 'package:html/dom.dart';
import 'package:kover/utils/extensions/element.dart';
import 'package:kover/utils/html_constants.dart';
import 'package:kover/utils/logging.dart';

class Style {
  const Style(this.selector, this.properties);

  final String selector;
  final Map<String, String> properties;

  (int, int, int) get specificity {
    final group = css.parseSelectorGroup(selector);

    var a = 0, b = 0, c = 0;

    for (var seq in group?.selectors ?? []) {
      for (var simple in seq.simpleSelectorSequences) {
        final s = simple.simpleSelector;

        if (s is IdSelector) {
          a++;
        } else if (s is ClassSelector ||
            s is AttributeSelector ||
            s is PseudoClassSelector) {
          b++;
        } else if (s is ElementSelector || s is PseudoElementSelector) {
          c++;
        }
      }
    }

    return (a, b, c);
  }
}

class EpubPagePreprocessor {
  final DocumentFragment _frag = DocumentFragment();
  final Map<String, Style> _styles = {};
  final Map<Element, List<Style>> _elementStyles = {};

  EpubPagePreprocessor(DocumentFragment fragment) {
    final wrapperElement = Element.tag('div');
    wrapperElement.className = HtmlConstants.kavitaWrapperClass;
    wrapperElement.append(fragment.clone(true));

    _frag.append(wrapperElement);
    _parseStyles();
    _precalculateStyles();
    _process();
  }

  DocumentFragment get processedFragment => _frag;

  void _process() {
    for (final child in _frag.children) {
      _walk(child);
    }
  }

  void _parseStyles() {
    final styles = <String, Map<String, String>>{};

    for (final stylesElement in _frag.querySelectorAll('style')) {
      styles.addAll(_parseStyleElement(stylesElement.innerHtml));
      stylesElement.remove();
    }

    _styles.addAll(
      styles.map(
        (selector, properties) =>
            MapEntry(selector, Style(selector, properties)),
      ),
    );
  }

  void _precalculateStyles() {
    for (final entry in _styles.entries) {
      final selector = entry.key;
      final style = entry.value;

      try {
        final matches = _frag.querySelectorAll(selector);

        for (final element in matches) {
          _elementStyles.putIfAbsent(element, () => []).add(style);
        }
      } catch (e) {
        log.d(
          'Failed to apply selector "$selector": $e',
        );
      }
    }
  }

  void _walk(Element element) {
    element.attributes[HtmlConstants.scrollIdAttribute] = element.scrollId;
    _inlineStyles(element);

    for (final child in element.children) {
      _walk(child);
    }
  }

  void _inlineStyles(Element element) {
    final matchingStyles = _elementStyles[element] ?? [];

    matchingStyles.sort((a, b) {
      final specA = a.specificity;
      final specB = b.specificity;

      if (specA.$1 != specB.$1) return specA.$1.compareTo(specB.$1);
      if (specA.$2 != specB.$2) return specA.$2.compareTo(specB.$2);
      return specA.$3.compareTo(specB.$3);
    });

    final stylesAttr = matchingStyles
        .map((s) => s.properties)
        .expand((p) => p.entries.map((e) => '${e.key}: ${e.value};'))
        .join(' ');

    var currentStyle = element.attributes['style'] ?? '';
    if (currentStyle.isNotEmpty && !currentStyle.trim().endsWith(';')) {
      currentStyle += ';';
    }
    element.attributes['style'] = '$currentStyle $stylesAttr'.trim();
  }

  static Map<String, Map<String, String>> _parseStyleElement(String cssString) {
    final sheet = css.parse(cssString);
    final visitor = _CssToMapVisitor();
    sheet.visit(visitor);

    return visitor.resultMap;
  }
}

class _CssToMapVisitor extends Visitor {
  final Map<String, Map<String, String>> resultMap = {};
  Set<String> currentSelectors = {};

  @override
  void visitRuleSet(RuleSet node) {
    final selectorGroup = node.selectorGroup;
    if (selectorGroup == null) return;

    currentSelectors = selectorGroup.selectors
        .map((s) => s.span?.text)
        .whereType<String>()
        .toSet();

    for (final selector in currentSelectors) {
      resultMap.putIfAbsent(selector, () => {});
    }

    super.visitRuleSet(node);
  }

  @override
  void visitDeclaration(Declaration node) {
    final expr = node.expression;
    if (expr == null) return;
    final printer = CssPrinter();
    expr.visit(printer);
    final value = printer.toString();
    for (final selector in currentSelectors) {
      resultMap[selector]![node.property] = value;
    }
    super.visitDeclaration(node);
  }
}
