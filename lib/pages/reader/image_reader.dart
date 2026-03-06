import 'package:flutter/material.dart';
import 'package:fluvita/pages/reader/horizontal_paged_reader.dart';
import 'package:fluvita/pages/reader/vertical_continuous_reader.dart';
import 'package:fluvita/pages/reader/reader_overlay.dart';
import 'package:fluvita/riverpod/providers/reader/reader_navigation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/providers/settings/image_reader_settings.dart';

class ImageReader extends ConsumerWidget {
  final int seriesId;
  final int chapterId;

  const ImageReader({
    super.key,
    required this.seriesId,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(imageReaderSettingsProvider(seriesId: seriesId));
    final navProvider = readerNavigationProvider(
      seriesId: seriesId,
      chapterId: chapterId,
    );

    return ReaderOverlay(
      seriesId: seriesId,
      chapterId: chapterId,
      onNextPage: () {
        settings.readDirection == .leftToRight
            ? ref.read(navProvider.notifier).nextPage()
            : ref.read(navProvider.notifier).previousPage();
      },
      onPreviousPage: () {
        settings.readDirection == .leftToRight
            ? ref.read(navProvider.notifier).previousPage()
            : ref.read(navProvider.notifier).nextPage();
      },
      onJumpToPage: (page) {
        ref.read(navProvider.notifier).jumpToPage(page);
      },
      child: switch (settings.readerMode) {
        ReaderMode.horizontal => HorizontalPagedReader(
          seriesId: seriesId,
          chapterId: chapterId,
        ),
        ReaderMode.vertical => VerticalContinuousReader(
          seriesId: seriesId,
          chapterId: chapterId,
        ),
      },
    );
  }
}
