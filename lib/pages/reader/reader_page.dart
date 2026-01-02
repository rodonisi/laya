import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:laya/pages/reader/epub_reader.dart';
import 'package:laya/pages/reader/image_reader.dart';
import 'package:laya/pages/reader/reader_controls.dart';
import 'package:laya/pages/reader/reader_header.dart';
import 'package:laya/riverpod/reader.dart';
import 'package:laya/widgets/async_value.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ReaderPage extends HookConsumerWidget {
  final int seriesId;
  final int? chapterId;

  const ReaderPage({super.key, required this.seriesId, this.chapterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiVisible = useState(false);

    final provider = readerProvider(
      seriesId: seriesId,
      chapterId: chapterId,
    );

    final book = ref.watch(provider);

    final readDirection = ref.watch(
      readDirectionProvider(seriesId: seriesId, chapterId: chapterId),
    );

    return Scaffold(
      body: GestureDetector(
        onPanEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx < 0) {
            readDirection == .rightToLeft
                ? ref.read(provider.notifier).nextPage()
                : ref.read(provider.notifier).previousPage();
          } else if (details.velocity.pixelsPerSecond.dx > 0) {
            readDirection == .rightToLeft
                ? ref.read(provider.notifier).previousPage()
                : ref.read(provider.notifier).nextPage();
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Async(
                asyncValue: book,
                data: (book) => switch (book.series.format) {
                  .epub => EpubReader(
                    chapterId: book.chapter.id,
                    page: book.currentPage,
                  ),
                  .cbz => ImageReader(
                    chapterId: book.chapter.id,
                    page: book.currentPage,
                    totalPages: book.totalPages,
                  ),
                  .unknown => const Center(
                    child: Text('Unsupported format'),
                  ),
                },
              ),
            ),
            Positioned.fill(
              child: Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: GestureDetector(
                      behavior: .translucent,
                      onTap: () => readDirection == .rightToLeft
                          ? ref.read(provider.notifier).previousPage()
                          : ref.read(provider.notifier).nextPage(),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: GestureDetector(
                      behavior: .translucent,
                      onTap: () => uiVisible.value = !uiVisible.value,
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: GestureDetector(
                      behavior: .translucent,
                      onTap: () => readDirection == .rightToLeft
                          ? ref.read(provider.notifier).nextPage()
                          : ref.read(provider.notifier).previousPage(),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: .topCenter,
              child:
                  ReaderHeader(
                        seriesId: seriesId,
                        chapterId: chapterId,
                      )
                      .animate(target: uiVisible.value ? 1.0 : 0.0)
                      .fadeIn(duration: 100.ms),
            ),
            Align(
              alignment: .bottomCenter,
              child: ReaderControls(chapterId: chapterId, seriesId: seriesId)
                  .animate(target: uiVisible.value ? 1.0 : 0.0)
                  .fadeIn(duration: 100.ms),
            ),
          ],
        ),
      ),
    );
  }
}
