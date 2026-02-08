import 'package:flutter/material.dart';
import 'package:fluvita/riverpod/reader_navigation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/pages/reader/epub_reader_controls.dart';
import 'package:fluvita/pages/reader/image_reader_controls.dart';
import 'package:fluvita/pages/reader/page_slider.dart';
import 'package:fluvita/riverpod/reader.dart';
import 'package:fluvita/utils/layout_constants.dart';

class ReaderControls extends HookConsumerWidget {
  final int seriesId;
  final int? chapterId;
  final void Function(int page)? onJumpToPage;
  const ReaderControls({
    super.key,
    required this.seriesId,
    this.chapterId,
    this.onJumpToPage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final format = ref.watch(
      readerProvider(seriesId: seriesId, chapterId: chapterId).select(
        (state) => state.value?.series.format,
      ),
    );
    return Card.filled(
      margin: LayoutConstants.mediumEdgeInsets,
      child: Padding(
        padding: LayoutConstants.smallEdgeInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: .end,
          children: [
            Row(
              children: [
                Expanded(
                  child: PageSlider(
                    seriesId: seriesId,
                    chapterId: chapterId,
                    onJumpToPage: (page) => ref
                        .read(
                          readerNavigationProvider(
                            seriesId: seriesId,
                            chapterId: chapterId,
                          ).notifier,
                        )
                        .jumpToPage(page),
                  ),
                ),
                if (format == .epub) const EpubReaderControls(),
                if (format == .cbz) const ImageReaderControls(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
