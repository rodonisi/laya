import 'package:fluvita/riverpod/api/book.dart';
import 'package:fluvita/riverpod/epub_reader_settings.dart';
import 'package:fluvita/riverpod/reader.dart';
import 'package:fluvita/riverpod/reader_navigation.dart';
import 'package:fluvita/utils/html_scroll_id.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:html/dom.dart' as dom;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'epub_reader.freezed.dart';
part 'epub_reader.g.dart';

typedef HtmlElement = dom.Element;

@freezed
sealed class EpubReaderState with _$EpubReaderState {
  const EpubReaderState._();

  const factory EpubReaderState.measuring({
    required int pageIndex,
    required int totalPages,
    required BookPageElementsResult pageElements,
    required String? scrollId,
    @Default(0) currentIndex,
    @Default([0]) List<int> pageBreaks,
    @Default(0) int subpageIndex,
    @Default(false) bool fromLast,
  }) = Measuring;

  const factory EpubReaderState.display({
    required int pageIndex,
    required int totalPages,
    required BookPageElementsResult pageElements,
    String? scrollId,
    @Default([0]) List<int> pageBreaks,
    @Default(0) int subpageIndex,
  }) = Display;

  T when<T>({
    required T Function(Measuring value) measuring,
    required T Function(Display value) display,
  }) {
    return switch (this) {
      Measuring() => measuring(this as Measuring),
      Display() => display(this as Display),
    };
  }

  T? whenOrNull<T>({
    T Function(Measuring value)? measuring,
    T Function(Display value)? display,
  }) {
    return switch (this) {
      Measuring() when measuring != null => measuring(this as Measuring),
      Display() when display != null => display(this as Display),
      _ => null,
    };
  }

  int? get scrollIdIndex {
    if (scrollId == null) return null;

    return pageElements.elements.indexWhere(
      (element) => element.scrollId == scrollId,
    );
  }

  int get pageStart => pageBreaks[subpageIndex];
  int get pageEnd => (subpageIndex + 1 < pageBreaks.length)
      ? pageBreaks[subpageIndex + 1]
      : pageElements.elements.length;

  String get currentPage {
    // If we have a single element that is the body itself, render it directly
    // to avoid double-nesting
    if (pageElements.elements.isEmpty) {
      return pageElements.wrapper.outerHtml;
    }

    final (:start, :end) = when(
      measuring: (data) {
        final endIndex = data.currentIndex;
        return (start: pageStart, end: endIndex);
      },
      display: (data) {
        return (start: pageStart, end: pageEnd);
      },
    );

    final container = pageElements.wrapper.clone(false)
      ..children.addAll(
        pageElements.elements.sublist(start, end).map((e) => e.clone(true)),
      );

    return container.outerHtml;
  }

  String? get firstScrollId {
    if (pageElements.elements.isEmpty) {
      return null;
    }

    final firstElement = pageElements.elements[pageStart];
    return firstElement.scrollId;
  }
}

@riverpod
class EpubReader extends _$EpubReader {
  @override
  Future<EpubReaderState> build({
    required int seriesId,
    required int chapterId,
  }) async {
    // force rerender on settings change
    ref.watch(epubReaderSettingsProvider);

    final readerState = await ref.watch(
      readerProvider(
        seriesId: seriesId,
        chapterId: chapterId,
      ).future,
    );

    final currentPage = ref
        .watch(
          readerNavigationProvider(seriesId: seriesId, chapterId: chapterId),
        )
        .currentPage;

    final page = await ref.watch(
      bookPageElementsProvider(
        chapterId: chapterId,
        page: currentPage,
      ).future,
    );

    if (page.elements.isEmpty) {
      // skip measuring for pages without elements
      return EpubReaderState.display(
        pageIndex: currentPage,
        totalPages: readerState.totalPages,
        pageElements: page,
      );
    }

    final hadState = state.value != null;
    final fromLast = (state.value != null)
        ? state.value!.pageIndex == currentPage + 1
        : false;

    return EpubReaderState.measuring(
      pageIndex: currentPage,
      totalPages: readerState.totalPages,
      pageElements: page,
      scrollId: hadState ? null : readerState.bookScrollId,
      fromLast: fromLast,
    );
  }

  Future<void> addElement() async {
    final current = await future;
    current.whenOrNull(
      measuring: (measuring) {
        if (measuring.subpageIndex + 1 < measuring.pageBreaks.length) {
          log.d(
            'next page already measured, converting to display with subpageIndex=${measuring.subpageIndex}',
          );
          state = AsyncData(
            EpubReaderState.display(
              pageIndex: measuring.pageIndex,
              totalPages: measuring.totalPages,
              pageElements: measuring.pageElements,
              subpageIndex: measuring.subpageIndex,
              pageBreaks: measuring.pageBreaks,
            ),
          );
          return;
        }

        // Check if we've already incremented past all elements and confirmed no overflow
        if (measuring.currentIndex >= measuring.pageElements.elements.length) {
          log.d('all elements measured and fit on current page');
          finishMeasuring(overflow: false);
          return;
        }

        state = AsyncData(
          measuring.copyWith(
            currentIndex: measuring.currentIndex + 1,
          ),
        );
      },
    );
  }

  Future<void> finishMeasuring({bool overflow = true}) async {
    final current = await future;
    current.whenOrNull(
      measuring: (measuring) {
        final scrollIdIdx = measuring.scrollIdIndex;
        final pageStart = measuring.pageBreaks[measuring.subpageIndex];
        final overflowIndex = measuring.currentIndex - 1;
        if (overflow &&
            measuring.currentIndex - pageStart == 1 &&
            overflowIndex >= 0 &&
            overflowIndex < measuring.pageElements.elements.length) {
          final fragments = _splitRenderableElement(
            measuring.pageElements.elements[overflowIndex],
          );

          if (fragments != null && fragments.length > 1) {
            final newElements = [
              ...measuring.pageElements.elements.sublist(0, overflowIndex),
              ...fragments,
              ...measuring.pageElements.elements.sublist(overflowIndex + 1),
            ];

            final updatedPageElements = measuring.pageElements.copyWith(
              elements: newElements,
            );

            state = AsyncData(
              measuring.copyWith(
                pageElements: updatedPageElements,
                currentIndex: pageStart,
              ),
            );
            return;
          }
        }
        // Only add a page break if the page overflowed
        // If overflow is false, all remaining elements fit on the current page
        final pageBreaks = <int>[
          ...measuring.pageBreaks,
          if (overflow) measuring.currentIndex - 1,
          if (overflow &&
              measuring.pageBreaks.isNotEmpty &&
              measuring.pageBreaks.last == measuring.currentIndex - 1)
            measuring.currentIndex,
        ];

        if ((measuring.fromLast &&
                measuring.currentIndex <
                    measuring.pageElements.elements.length) ||
            (measuring.scrollId != null &&
                scrollIdIdx != null &&
                scrollIdIdx >= pageBreaks.last)) {
          log.d('fast forward, measuring next page');

          state = AsyncData(
            measuring.copyWith(
              pageBreaks: pageBreaks,
              subpageIndex: pageBreaks.length - 1,
              currentIndex: pageBreaks.last,
            ),
          );
          return;
        }

        log.d(
          'finishing measuring at ${measuring.currentIndex}/${measuring.pageElements.elements.length}',
        );

        state = AsyncData(
          EpubReaderState.display(
            pageIndex: measuring.pageIndex,
            totalPages: measuring.totalPages,
            pageElements: measuring.pageElements,
            scrollId: null,
            pageBreaks: pageBreaks,
            subpageIndex: measuring.subpageIndex,
          ),
        );
      },
    );
  }

  Future<void> nextPage() async {
    final current = await future;
    log.d('nextPage called, current state type: ${current.runtimeType}');

    // Guard: don't allow navigation while measuring
    if (current is Measuring) {
      log.d('ignoring nextPage - already measuring');
      return;
    }

    current.whenOrNull(
      display: (display) async {
        log.d(
          'moving to next page, subpage ${display.subpageIndex} -> ${display.subpageIndex + 1}',
        );
        log.d(
          'pageEnd: ${display.pageEnd}, elements.length: ${display.pageElements.elements.length}',
        );

        if (display.pageEnd >= display.pageElements.elements.length) {
          log.d('at last subpage, moving to next chapter page');
          ref
              .read(
                readerNavigationProvider(
                  seriesId: seriesId,
                  chapterId: chapterId,
                ).notifier,
              )
              .nextPage();
          return;
        }

        log.d(
          'creating measuring state with subpageIndex: ${display.subpageIndex + 1}',
        );
        final next = EpubReaderState.measuring(
          pageIndex: display.pageIndex,
          totalPages: display.totalPages,
          pageElements: display.pageElements,
          scrollId: display.scrollId,
          pageBreaks: display.pageBreaks,
          subpageIndex: display.subpageIndex + 1,
          currentIndex: display.pageEnd,
        );

        log.d('saving progress with scrollId: ${next.firstScrollId}');
        await ref
            .read(
              readerProvider(
                seriesId: seriesId,
                chapterId: chapterId,
              ).notifier,
            )
            .saveProgress(
              page: display.pageIndex,
              scrollId: next.firstScrollId,
            );

        log.d('setting state to measuring');
        state = AsyncData(next);
        log.d('state updated');
      },
      measuring: (measuring) {
        log.d('ERROR: nextPage called while in measuring state!');
      },
    );
  }

  Future<void> previousPage() async {
    final current = await future;
    log.d('previousPage called, current state type: ${current.runtimeType}');

    // Guard: don't allow navigation while measuring
    if (current is Measuring) {
      log.d('ignoring previousPage - already measuring');
      return;
    }

    current.whenOrNull(
      display: (display) async {
        log.d('moving to previous page');
        if (display.subpageIndex <= 0) {
          log.d('at first subpage, moving to previous chapter page');
          ref
              .read(
                readerNavigationProvider(
                  seriesId: seriesId,
                  chapterId: chapterId,
                ).notifier,
              )
              .previousPage();
          return;
        }

        final next = display.copyWith(subpageIndex: display.subpageIndex - 1);

        await ref
            .read(
              readerProvider(
                seriesId: seriesId,
                chapterId: chapterId,
              ).notifier,
            )
            .saveProgress(
              page: display.pageIndex,
              scrollId: next.firstScrollId,
            );

        state = AsyncData(next);
      },
    );
  }

  Future<void> jumpToPage(int page) async {
    log.d('Jumping to page $page');

    ref
        .read(
          readerNavigationProvider(
            seriesId: seriesId,
            chapterId: chapterId,
          ).notifier,
        )
        .jumpToPage(page);
  }
}

List<dom.Element>? _splitRenderableElement(dom.Element element) {
  return _splitByChildren(element);
}

List<dom.Element>? _splitByChildren(dom.Element element) {
  final children = element.children;
  if (children.isEmpty) {
    return null;
  }

  if (children.length >= 2) {
    final splitIndex = children.length ~/ 2;
    final prefix = element.clone(false);
    prefix.children.addAll(
      children.sublist(0, splitIndex).map((child) => child.clone(true)),
    );

    final suffix = element.clone(false);
    suffix.children.addAll(
      children.sublist(splitIndex).map((child) => child.clone(true)),
    );

    return [prefix, suffix];
  }

  final child = children.first;
  final splitChild = _splitRenderableElement(child);
  if (splitChild != null) {
    final prefix = element.clone(false);
    prefix.children.add(splitChild.first);

    final suffix = element.clone(false);
    suffix.children.add(splitChild.last);

    return [prefix, suffix];
  }

  return null;
}
