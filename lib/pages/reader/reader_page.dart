import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/pages/reader/epub_reader.dart';
import 'package:kover/pages/reader/image_reader.dart';
import 'package:kover/riverpod/managers/sync_manager.dart';
import 'package:kover/riverpod/providers/reader//reader.dart';
import 'package:kover/widgets/async_value.dart';

class ReaderPage extends HookConsumerWidget {
  final int seriesId;
  final int? chapterId;

  const ReaderPage({super.key, required this.seriesId, this.chapterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = readerProvider(
      seriesId: seriesId,
      chapterId: chapterId,
    );

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) return;

        // Schedules the sync to happen right after the pop is processed
        Future.microtask(
          () => ref.read(syncManagerProvider.notifier).syncProgress(),
        );
      },
      child: Scaffold(
        body: SafeArea(
          child: Async(
            asyncValue: ref.watch(provider),
            data: (data) {
              return switch (data.series.format) {
                .archive => ImageReader(
                  seriesId: data.series.id,
                  chapterId: data.chapter.id,
                ),
                .epub => EpubReader(
                  seriesId: data.series.id,
                  chapterId: data.chapter.id,
                ),
                _ => Center(
                  child: Text('Unsupported format: ${data.series.format}'),
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}
