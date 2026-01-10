import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fluvita/pages/reader/reader_overlay.dart';
import 'package:fluvita/riverpod/epub_reader.dart';
import 'package:fluvita/riverpod/epub_reader_settings.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    final reader = epubReaderProvider(
      seriesId: seriesId,
      chapterId: chapterId,
    );

    return ReaderOverlay(
      seriesId: seriesId,
      chapterId: chapterId,
      onNextPage: () {
        ref.read(reader.notifier).nextPage();
      },
      onPreviousPage: () {
        ref.read(reader.notifier).previousPage();
      },
      onJumpToPage: (page) {
        ref.read(reader.notifier).jumpToPage(page);
      },
      child: Async(
        asyncValue: ref.watch(reader),
        data: (data) {
          return data.when(
            measuring: (data) {
              return MeasureContent(
                state: data,
                seriesId: seriesId,
                chapterId: chapterId,
              );
            },
            display: (data) => RenderContent(html: data.currentPage),
          );
        },
      ),
    );
  }
}

class MeasureContent extends ConsumerWidget {
  final int seriesId;
  final int chapterId;
  final Measuring state;
  const MeasureContent({
    super.key,
    required this.state,
    required this.seriesId,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = epubReaderProvider(
      seriesId: seriesId,
      chapterId: chapterId,
    );
    final key = GlobalKey();

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final renderBox =
              key.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox == null) {
            return;
          }

          if (renderBox.size.height > constraints.maxHeight) {
            ref.read(provider.notifier).finishMeasuring();
          } else {
            ref.read(provider.notifier).addElement();
          }
        });

        return Stack(
          children: [
            Positioned.fill(
              child: Offstage(
                child: SingleChildScrollView(
                  child: RenderContent(
                    key: key,
                    html: state.currentPage,
                  ),
                ),
              ),
            ),
            Align(
              alignment: .center,
              child: CircularProgressIndicator(),
            ),
          ],
        );
      },
    );
  }
}

class RenderContent extends ConsumerWidget {
  final String html;

  const RenderContent({super.key, required this.html});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final epubSettings = ref.watch(epubReaderSettingsProvider);
    return Padding(
      padding: EdgeInsets.all(epubSettings.marginSize),
      child: Column(
        mainAxisSize: .min,
        children: [
          Flexible(
            child: HtmlWidget(
              html,
              textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: epubSettings.fontSize,
                height: epubSettings.lineHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
