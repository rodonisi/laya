import 'package:fluvita/riverpod/api/book.dart';
import 'package:fluvita/riverpod/epub_reader_settings.dart';
import 'package:fluvita/riverpod/reader.dart';
import 'package:fluvita/utils/html_scroll_id.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:html/dom.dart' as dom;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'epub_reader.freezed.dart';
part 'epub_reader.g.dart';

typedef HtmlElement = dom.Element;

class HtmlElementsList {
  final List<dom.Element> elements;
  const HtmlElementsList(this.elements);
}

@freezed
sealed class EpubReaderState with _$EpubReaderState {
  const EpubReaderState._();

  const factory EpubReaderState.measuring({
    required int pageIndex,
    required int totalPages,
    required HtmlElementsList pageElements,
    required HtmlElement containerElement,
    String? scrollId,
    @Default(0) currentIndex,
    @Default([0]) List<int> pageBreaks,
    @Default(0) int subpageIndex,
    @Default(false) bool fromLast,
  }) = Measuring;

  const factory EpubReaderState.display({
    required int pageIndex,
    required int totalPages,
    required HtmlElementsList pageElements,
    required HtmlElement containerElement,
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
      return containerElement.outerHtml;
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

    final container = containerElement.clone(false)
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

    final page = await ref.watch(
      bookPageElementsProvider(
        chapterId: chapterId,
        page: readerState.currentPage,
      ).future,
    );

    if (page.elements.isEmpty) {
      // skip measuring for pages without elements
      return EpubReaderState.display(
        pageIndex: readerState.currentPage,
        totalPages: readerState.totalPages,
        pageElements: HtmlElementsList([]),
        containerElement: page.wrapper,
      );
    }

    final hadState = state.value != null;
    final fromLast = (state.value != null)
        ? state.value!.pageIndex == readerState.currentPage + 1
        : false;

    return EpubReaderState.measuring(
      pageIndex: readerState.currentPage,
      totalPages: readerState.totalPages,
      pageElements: HtmlElementsList(page.elements),
      containerElement: page.wrapper,
      scrollId: hadState ? null : readerState.bookScrollId,
      fromLast: fromLast,
    );
  }

  Future<void> addElement() async {
    final current = await future;
    current.whenOrNull(
      measuring: (measuring) {
        if (measuring.subpageIndex + 1 < measuring.pageBreaks.length) {
          log.d('next page already measured');
          state = AsyncData(
            EpubReaderState.display(
              pageIndex: measuring.pageIndex,
              totalPages: measuring.totalPages,
              pageElements: measuring.pageElements,
              containerElement: measuring.containerElement,
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
            containerElement: measuring.containerElement,
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

    current.whenOrNull(
      display: (display) async {
        log.d('moving to next page');
        if (display.pageEnd + 1 >= display.pageElements.elements.length) {
          log.d('already at last page, cannot move to next page');
          ref
              .read(
                readerProvider(
                  seriesId: seriesId,
                  chapterId: chapterId,
                ).notifier,
              )
              .nextPage();
          return;
        }

        final next = EpubReaderState.measuring(
          pageIndex: display.pageIndex,
          totalPages: display.totalPages,
          pageElements: display.pageElements,
          containerElement: display.containerElement,
          scrollId: display.scrollId,
          pageBreaks: display.pageBreaks,
          subpageIndex: display.subpageIndex + 1,
          currentIndex: display.pageEnd,
        );

        await ref
            .read(
              readerProvider(
                seriesId: seriesId,
                chapterId: chapterId,
              ).notifier,
            )
            .reportProgress(
              scrollId: next.firstScrollId,
            );

        state = AsyncData(next);
      },
    );
  }

  Future<void> previousPage() async {
    final current = await future;

    current.whenOrNull(
      display: (display) async {
        log.d('moving to previous page');
        if (display.subpageIndex <= 0) {
          log.d('already at first page, cannot move to previous page');
          ref
              .read(
                readerProvider(
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
            .reportProgress(
              scrollId: next.firstScrollId,
            );

        state = AsyncData(next);
      },
    );
  }

  Future<void> jumpToPage(int page) async {
    log.d('Jumping to page $page');

    ref
        .read(readerProvider(seriesId: seriesId, chapterId: chapterId).notifier)
        .gotoPage(page);
  }
}
