import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluvita/pages/reader/reader_overlay.dart';
import 'package:fluvita/riverpod/reader.dart';
import 'package:fluvita/riverpod/reader_navigation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/api/reader.dart';
import 'package:fluvita/riverpod/image_reader_settings.dart';
import 'package:fluvita/widgets/async_value.dart';

class ImageReader extends HookConsumerWidget {
  final int seriesId;
  final int chapterId;

  const ImageReader({
    super.key,
    required this.seriesId,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(imageReaderSettingsProvider);
    final provider = readerProvider(seriesId: seriesId, chapterId: chapterId);

    // Watch reader state for metadata (stable)
    final state = ref.watch(provider).value;
    if (state == null) {
      return Center(
        child: Text('Failed to load reader state.'),
      );
    }

    // Watch navigation state for current page
    final navProvider = readerNavigationProvider(
      seriesId: seriesId,
      chapterId: chapterId,
    );
    final navState = ref.watch(navProvider);

    final pageController = usePageController(initialPage: navState.currentPage);

    // Sync controller when navigation changes externally (slider/overlay)
    ref.listen(navProvider.select((s) => s.currentPage), (previous, next) {
      if (pageController.hasClients && pageController.page?.round() != next) {
        pageController.jumpToPage(next);
      }
    });

    return ReaderOverlay(
      seriesId: seriesId,
      chapterId: chapterId,
      onNextPage: () {
        ref.read(navProvider.notifier).nextPage();
      },
      onPreviousPage: () {
        ref.read(navProvider.notifier).previousPage();
      },
      onJumpToPage: (page) {
        ref.read(navProvider.notifier).jumpToPage(page);
      },
      child: PageView.builder(
        controller: pageController,
        allowImplicitScrolling: true,
        reverse:
            settings.readerMode == .horizontal &&
            settings.readDirection == .leftToRight,
        scrollDirection: settings.readerMode == .vertical
            ? .vertical
            : .horizontal,
        itemCount: state.totalPages,
        pageSnapping: settings.readerMode == .horizontal,
        onPageChanged: (index) {
          // Update navigation state only (no rebuild!)
          ref.read(navProvider.notifier).setPage(index);
        },
        itemBuilder: (context, index) {
          return Async(
            asyncValue: ref.watch(
              readerImageProvider(chapterId: chapterId, page: index),
            ),
            data: (data) {
              return Image.memory(
                data,
                fit: settings.scaleType == .fitWidth ? .fitWidth : .fitHeight,
              );
            },
          );
        },
      ),
    );
  }
}
