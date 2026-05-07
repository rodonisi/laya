import 'package:csslib/parser.dart' as css;
import 'package:csslib/visitor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/dom.dart';
import 'package:kover/pages/reader/overlay/reader_overlay.dart';
import 'package:kover/riverpod/providers/reader/epub_reader.dart';
import 'package:kover/riverpod/providers/settings/epub_reader_settings.dart';
import 'package:kover/utils/cached_image_factory.dart';
import 'package:kover/utils/extensions/element.dart';
import 'package:kover/utils/logging.dart';
import 'package:kover/widgets/util/async_value.dart';

class EpubReader extends HookConsumerWidget {
  final int seriesId;
  final int chapterId;

  const EpubReader({
    super.key,
    required this.seriesId,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = epubNavigationProvider(
      seriesId: seriesId,
      chapterId: chapterId,
    );

    return ReaderOverlay(
      seriesId: seriesId,
      chapterId: chapterId,
      onNextPage: () {
        ref.read(nav.notifier).nextPage();
      },
      onPreviousPage: () {
        ref.read(nav.notifier).previousPage();
      },
      onJumpToPage: (page) {
        ref.read(nav.notifier).jumpToPage(page);
      },
      child: Async(
        asyncValue: ref.watch(nav),
        data: (navState) => HookConsumer(
          builder: (context, ref, child) {
            final controller = usePageController(
              initialPage: navState.page,
            );

            ref.listen(nav.selectAsync((s) => s.page), (previous, next) async {
              final previousPage = await previous;
              final nextPage = await next;

              if (controller.hasClients &&
                  controller.page?.round() != nextPage) {
                final isSequential =
                    previousPage != null &&
                    (nextPage - previousPage).abs() == 1;

                isSequential
                    ? controller.animateToPage(
                        nextPage,
                        duration: 200.ms,
                        curve: Curves.easeInOut,
                      )
                    : controller.jumpToPage(nextPage);
              }
            });

            return Stack(
              children: [
                Positioned.fill(
                  child: Offstage(
                    offstage: !navState.ready,
                    child: PageView.builder(
                      controller: controller,
                      itemCount: navState.totalPages,
                      allowImplicitScrolling: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return _Page(
                          seriesId: seriesId,
                          chapterId: chapterId,
                          page: index,
                        );
                      },
                    ),
                  ),
                ),
                if (!navState.ready)
                  const Positioned.fill(
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Page extends HookConsumerWidget {
  final int seriesId;
  final int chapterId;
  final int page;

  const _Page({
    required this.seriesId,
    required this.chapterId,
    required this.page,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reflow = ref.watch(
      epubReflowProvider(
        seriesId: seriesId,
        chapterId: chapterId,
        page: page,
      ),
    );
    final nav = epubNavigationProvider(
      seriesId: seriesId,
      chapterId: chapterId,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: _MeasureContent(
            seriesId: seriesId,
            chapterId: chapterId,
            page: page,
          ),
        ),
        Positioned.fill(
          child: Async(
            asyncValue: ref.watch(nav),
            data: (navState) {
              return Async(
                asyncValue: reflow,
                data: (reflowState) {
                  // include buffer spinner page if currently measuring.
                  final count = reflowState.status == .measuring
                      ? reflowState.subpages.length + 1
                      : reflowState.subpages.length;

                  return HookConsumer(
                    builder: (context, ref, child) {
                      final controller = usePageController(
                        initialPage: navState.subpage,
                      );

                      ref.listen(nav, (
                        previous,
                        next,
                      ) async {
                        next.whenData((next) async {
                          if (next.page != page) return;

                          final previousSubpage = previous?.value?.subpage;
                          final newSubpage = next.subpage;

                          if (controller.hasClients &&
                              controller.page?.round() != newSubpage) {
                            final isSequential =
                                previousSubpage != null &&
                                (newSubpage - previousSubpage).abs() == 1;

                            isSequential
                                ? controller.animateToPage(
                                    newSubpage,
                                    duration: 200.ms,
                                    curve: Curves.easeInOut,
                                  )
                                : controller.jumpToPage(newSubpage);
                          }
                        });
                      });

                      return PageView.builder(
                        controller: controller,
                        allowImplicitScrolling: true,
                        pageSnapping: true,
                        itemCount: count,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          if (index >= reflowState.subpages.length) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return SingleChildScrollView(
                            child: _RenderContent(
                              seriesId: seriesId,
                              html: reflowState.subpages[index].outerHtml,
                              styles: reflowState.page.styles,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MeasureContent extends HookConsumerWidget {
  final int seriesId;
  final int chapterId;
  final int page;
  const _MeasureContent({
    required this.seriesId,
    required this.chapterId,
    required this.page,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = useState(GlobalKey());
    final provider = epubReflowProvider(
      seriesId: seriesId,
      chapterId: chapterId,
      page: page,
    );
    final reflow = ref.watch(provider);
    final imageCache = useState(CachedImageFactory());

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await WidgetsBinding.instance.endOfFrame;
          final renderBox =
              key.value.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox == null) {
            return;
          }

          if (!renderBox.hasSize ||
              renderBox.size.height <= constraints.maxHeight) {
            await ref.read(provider.notifier).addElement();
          } else {
            await ref.read(provider.notifier).overflow();
          }
        });

        return Async(
          asyncValue: reflow,
          data: (data) => Offstage(
            child: Column(
              mainAxisSize: .min,
              children: [
                _RenderContent(
                  seriesId: seriesId,
                  key: key.value,
                  styles: data.page.styles,
                  html: (data.buffer ?? DocumentFragment()).outerHtml,
                  imageCache: imageCache.value,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RenderContent extends ConsumerWidget {
  final int seriesId;
  final String html;
  final Map<String, Map<String, String>> styles;
  final CachedImageFactory? imageCache;

  const _RenderContent({
    super.key,
    required this.seriesId,
    required this.html,
    required this.styles,
    this.imageCache,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final epubSettings = ref.watch(
      epubReaderSettingsProvider(seriesId: seriesId),
    );

    final inlineStyles = _inlineStyles(html);

    return Async(
      asyncValue: epubSettings,
      data: (epubSettings) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(epubSettings.marginSize),
          child: HtmlWidget(
            html,
            buildAsync: false,
            enableCaching: true,
            factoryBuilder: () => imageCache ?? CachedImageFactory(),
            customStylesBuilder: (element) {
              var matched = <(String, (int, int, int))>[];
              for (final selector in styles.keys) {
                if (element.matchesSelector(selector)) {
                  matched.add((selector, specificities[selector]!));
                }
              }

              log.i(
                'Element ${element.localName} matches selectors: ${matched.map((e) => e.$1).join(', ')}',
              );

              matched.sort((a, b) {
                final specA = a.$2;
                final specB = b.$2;

                if (specA.$1 != specB.$1) return specA.$1.compareTo(specB.$1);
                if (specA.$2 != specB.$2) return specA.$2.compareTo(specB.$2);
                return specA.$3.compareTo(specB.$3);
              });

              final result = <String, String>{};
              for (final (selector, _) in matched) {
                result.addAll(styles[selector]!);
              }

              return result;
            },
            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: epubSettings.fontSize,
              height: epubSettings.lineHeight,
              wordSpacing: epubSettings.wordSpacing,
              letterSpacing: epubSettings.letterSpacing,
            ),
          ),
        ),
      ),
    );
  }

  (int, int, int) _computeSpecificity(String selector) {
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

  String _inlineStyles(String html) {
    final specificities = Map.fromEntries(
      styles.keys.map((selector) {
        return MapEntry(selector, _computeSpecificity(selector));
      }),
    );

    final document = DocumentFragment.html(html);

    void applyStyles(Element element) {
      for (final selector in styles.keys) {
        if (element.matchesSelector(selector)) {
          final style = styles[selector]!;
          final existingStyle = element.attributes['style'] ?? '';
          final newStyle = [
            existingStyle,
            ...style.entries.map((e) => '${e.key}: ${e.value};'),
          ].where((s) => s.isNotEmpty).join(' ');

          element.attributes['style'] = newStyle;
        }
      }

      for (final child in element.children) {
        applyStyles(child);
      }
    }

    return '';
  }
}
