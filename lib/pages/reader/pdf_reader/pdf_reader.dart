import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/pages/reader/overlay/reader_overlay.dart';
import 'package:kover/pages/reader/pdf_reader/pdf_toc_drawer.dart';
import 'package:kover/riverpod/providers/book.dart';
import 'package:kover/riverpod/providers/reader/reader.dart';
import 'package:kover/riverpod/providers/reader/reader_navigation.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfControllerHook extends Hook<PdfViewerController> {
  const PdfControllerHook();

  @override
  PdfViewerControllerHookState createState() => PdfViewerControllerHookState();
}

class PdfViewerControllerHookState
    extends HookState<PdfViewerController, PdfControllerHook> {
  late final PdfViewerController controller;

  @override
  void initHook() {
    super.initHook();
    controller = PdfViewerController();
  }

  @override
  PdfViewerController build(BuildContext context) => controller;
}

PdfViewerController usePdfViewerController() => use(const PdfControllerHook());

class PdfReader extends HookConsumerWidget {
  final int seriesId;
  final int chapterId;

  const PdfReader({super.key, required this.seriesId, required this.chapterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = usePdfViewerController();
    final toc = useState<List<PdfOutlineNode>>([]);

    final navProvider = readerNavigationProvider(
      seriesId: seriesId,
      chapterId: chapterId,
    );

    final reader = ref.watch(
      readerProvider(seriesId: seriesId, chapterId: chapterId),
    );
    final pdf = ref.watch(pdfProvider(chapterId: chapterId));

    ref.listen(navProvider, (previous, next) async {
      if (!controller.isReady || next.fromObserver) return;

      if (previous?.currentPage != next.currentPage) {
        await controller.goToPage(pageNumber: next.currentPage);
      }
    });

    return Async(
      asyncValue: reader,
      data: (readerState) {
        return ReaderOverlay(
          chapterId: chapterId,
          seriesId: seriesId,
          onNextPage: () => ref.read(navProvider.notifier).nextPage(),
          onPreviousPage: () => ref.read(navProvider.notifier).previousPage(),
          onJumpToPage: (page) =>
              ref.read(navProvider.notifier).jumpToPage(page),
          endDrawer: toc.value.isNotEmpty
              ? PdfTocDrawer(
                  seriesId: seriesId,
                  chapterId: chapterId,
                  controller: controller,
                  toc: toc.value,
                )
              : null,
          child: Async(
            asyncValue: pdf,
            data: (data) {
              return PdfViewer.data(
                data.data,
                controller: controller,
                sourceName: chapterId.toString(),
                initialPageNumber: readerState.initialPage,
                params: PdfViewerParams(
                  onViewerReady: (document, controller) async {
                    toc.value = await document.loadOutline();
                  },
                  onPageChanged: (page) {
                    if (page == null) return;

                    ref
                        .read(navProvider.notifier)
                        .jumpToPage(page, fromObserver: true);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
