import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluvita/riverpod/reader.dart';
import 'package:fluvita/riverpod/reader_navigation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/api/reader.dart';
import 'package:fluvita/riverpod/image_reader_settings.dart';
import 'package:fluvita/widgets/async_value.dart';

class HorizontalPagedReader extends HookConsumerWidget {
  final int seriesId;
  final int chapterId;

  const HorizontalPagedReader({
    super.key,
    required this.seriesId,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(imageReaderSettingsProvider);
    final provider = readerProvider(seriesId: seriesId, chapterId: chapterId);

    final navProvider = readerNavigationProvider(
      seriesId: seriesId,
      chapterId: chapterId,
    );
    final navState = ref.watch(navProvider);

    final pageController = usePageController(initialPage: navState.currentPage);

    ref.listen(navProvider.select((s) => s.currentPage), (previous, next) {
      if (pageController.hasClients && pageController.page?.round() != next) {
        final isSequential = previous != null && (next - previous).abs() == 1;

        isSequential
            ? pageController.animateToPage(
                next,
                duration: 200.ms,
                curve: Curves.easeInOut,
              )
            : pageController.jumpToPage(next);
      }
    });
    return Async(
      asyncValue: ref.watch(provider),
      data: (state) {
        return PageView.builder(
          controller: pageController,
          allowImplicitScrolling: true,
          scrollDirection: .horizontal,
          itemCount: state.totalPages,
          pageSnapping: true,
          onPageChanged: (index) {
            ref.read(navProvider.notifier).jumpToPage(index);
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
        );
      },
    );
  }
}
