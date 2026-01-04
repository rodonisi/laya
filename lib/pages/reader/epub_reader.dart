import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fluvita/pages/reader/reader_overlay.dart';
import 'package:fluvita/riverpod/reader.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/api/book.dart';
import 'package:fluvita/riverpod/epub_reader_settings.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:html/parser.dart';

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
    final settings = ref.watch(epubReaderSettingsProvider);

    return Async(
      asyncValue: ref.watch(
        readerProvider(seriesId: seriesId, chapterId: chapterId),
      ),
      data: (data) {
        return HookBuilder(
          builder: (context) {
            final controller = usePageController();
            return ReaderOverlay(
              seriesId: seriesId,
              chapterId: chapterId,
              onNextPage: () {
                settings.readDirection == .rightToLeft
                    ? controller.previousPage(
                        duration: 100.ms,
                        curve: Curves.easeInOut,
                      )
                    : controller.nextPage(
                        duration: 100.ms,
                        curve: Curves.easeInOut,
                      );
              },
              onPreviousPage: () {
                settings.readDirection == .rightToLeft
                    ? controller.nextPage(
                        duration: 100.ms,
                        curve: Curves.easeInOut,
                      )
                    : controller.previousPage(
                        duration: 100.ms,
                        curve: Curves.easeInOut,
                      );
              },
              onJumpToPage: (page) {
                controller.jumpToPage(page);
              },
              child: PageView.builder(
                allowImplicitScrolling: true,
                itemCount: data.totalPages,
                controller: controller,
                onPageChanged: (page) {
                  ref
                      .read(
                        readerProvider(
                          seriesId: seriesId,
                          chapterId: chapterId,
                        ).notifier,
                      )
                      .gotoPage(page);
                },
                itemBuilder: (context, index) {
                  return Async(
                    asyncValue: ref.watch(
                      bookPageProvider(
                        chapterId: chapterId,
                        page: index,
                      ),
                    ),
                    data: (data) {
                      final doc = parse(data);
                      final chunks = useState<List<String>>([]);

                      // split into chunks filling the screen height

                      return SingleChildScrollView(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Padding(
                              padding: EdgeInsetsGeometry.all(
                                settings.marginSize,
                              ),
                              child: HtmlWidget(
                                data,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontSize: settings.fontSize,
                                      height: settings.lineHeight,
                                    ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
