import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluvita/riverpod/managers/download_manager.dart';
import 'package:fluvita/riverpod/providers/chapter.dart';
import 'package:fluvita/riverpod/providers/download.dart';
import 'package:fluvita/riverpod/providers/series.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:fluvita/widgets/cover_image.dart';
import 'package:fluvita/widgets/sliver_bottom_padding.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DownloadQueuePage extends ConsumerWidget {
  const DownloadQueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasDls = ref.watch(
      downloadManagerProvider.select(
        (state) => state.value?.downloadQueue.isNotEmpty ?? false,
      ),
    );

    return Scaffold(
      body: CustomScrollView(
        physics: hasDls ? null : const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            title: const Text('Download Queue'),
            actions: [
              if (hasDls) const CancellAllAction(),
            ],
          ),
          const SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: LayoutConstants.mediumPadding,
            ),
            sliver: DownloadQueueList(),
          ),
          const SliverBottomPadding(),
        ],
      ),
    );
  }
}

class CancellAllAction extends ConsumerWidget {
  const CancellAllAction({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: () async {
        await ref.read(downloadManagerProvider.notifier).cancelAll();
      },
      child: const Text('Cancel All'),
    );
  }
}

class DownloadQueueList extends ConsumerWidget {
  const DownloadQueueList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queued = ref.watch(downloadManagerProvider);
    return AsyncSliver(
      asyncValue: queued,
      data: (data) {
        if (data.downloadQueue.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: Text('No downloads in queue')),
          );
        }
        final queued = data.downloadQueue.toList();
        return SliverList.builder(
          itemCount: queued.length,
          itemBuilder: (context, index) {
            return DownloadQueueItem(chapterId: queued[index]);
          },
        );
      },
    );
  }
}

class DownloadQueueItem extends ConsumerWidget {
  final int chapterId;

  const DownloadQueueItem({
    super.key,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapter = ref.watch(chapterProvider(chapterId: chapterId));
    final series = ref.watch(seriesForChapterProvider(chapterId: chapterId));

    final progress = ref.watch(
      chapterDownloadProgressProvider(chapterId: chapterId),
    );
    return Card.filled(
      clipBehavior: .hardEdge,
      child: Padding(
        padding: LayoutConstants.smallEdgeInsets,
        child: Row(
          spacing: LayoutConstants.mediumPadding,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(LayoutConstants.smallPadding),
              child: SizedBox(
                height: LayoutConstants.largestIcon,
                child: ChapterCoverImage(chapterId: chapterId),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: .start,
                spacing: LayoutConstants.smallPadding,
                children: [
                  Async(
                    asyncValue: series,
                    data: (series) => Text(
                      series.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: .ellipsis,
                    ),
                  ),
                  Async(
                    asyncValue: chapter,
                    data: (chapter) => Text(
                      chapter.title,
                      style: Theme.of(context).textTheme.titleSmall,
                      overflow: .ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox.square(
              dimension: LayoutConstants.mediumIcon,
              child: Async(
                asyncValue: progress,
                data: (progress) => CircularProgressIndicator(
                  value: progress,
                ),
              ),
            ),
            IconButton(
              onPressed: () async {
                await ref
                    .read(downloadManagerProvider.notifier)
                    .cancel(chapterId);
              },
              icon: const Icon(LucideIcons.trash2),
            ),
          ],
        ),
      ),
    );
  }
}
