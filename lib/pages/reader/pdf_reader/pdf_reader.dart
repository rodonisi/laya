import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/pages/reader/overlay/reader_overlay.dart';
import 'package:kover/pages/reader/pdf_reader/pdf_toc_drawer.dart';
import 'package:kover/riverpod/providers/book.dart';
import 'package:kover/riverpod/providers/reader/reader.dart';
import 'package:kover/riverpod/providers/reader/reader_navigation.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
    final defaultZoom = useState(1.0);

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
          extraControls: _PdfExtraControls(
            controller: controller,
            defaultZoom: defaultZoom,
          ),
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
                    defaultZoom.value = controller.currentZoom;
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

class _PdfExtraControls extends StatelessWidget {
  const _PdfExtraControls({
    required this.controller,
    required this.defaultZoom,
  });

  final PdfViewerController controller;
  final ValueNotifier<double> defaultZoom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutConstants.smallPadding,
      ),
      child: Row(
        mainAxisAlignment: .end,
        spacing: LayoutConstants.mediumPadding,
        children: [
          IconButton(
            onPressed: () {
              controller.zoomUp();
            },
            icon: const Icon(LucideIcons.zoomIn),
          ),
          IconButton(
            onPressed: () {
              controller.zoomDown();
            },
            icon: const Icon(LucideIcons.zoomOut),
          ),
          IconButton(
            onPressed: () {
              controller.setZoom(
                controller.centerPosition,
                defaultZoom.value,
              );
            },
            icon: const Icon(LucideIcons.scan),
          ),
        ],
      ),
    );
  }
}
