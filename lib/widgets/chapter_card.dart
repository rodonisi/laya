import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluvita/models/chapter_model.dart';
import 'package:fluvita/riverpod/api/chapter.dart';
import 'package:fluvita/riverpod/api/reader.dart';
import 'package:fluvita/riverpod/download/chapter_config.dart';
import 'package:fluvita/riverpod/download/download_manager.dart';
import 'package:fluvita/riverpod/router.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:fluvita/widgets/actions_menu.dart';
import 'package:fluvita/widgets/cover_card.dart';
import 'package:fluvita/widgets/cover_image.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart'; // Import for icons

class ChapterCard extends HookConsumerWidget {
  const ChapterCard({
    super.key,
    required this.chapter,
    required this.seriesId,
  });

  final ChapterModel chapter;
  final int seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chapterProvider(chapterId: chapter.id);

    final state = useState(chapter);

    ref.listen(provider, (previous, next) {
      if (next.hasValue) {
        // keep the title from the argument model as the chapter endpoint may return a different title
        state.value = next.value!.copyWith(title: chapter.title);
      }
    });

    useEffect(() {
      state.value = chapter;
      return null;
    }, [chapter]);

    final markReadProvider = markChapterReadProvider(
      seriesId: seriesId,
      chapterId: state.value.id,
    );

    final downloadManager = ref.watch(
      downloadManagerProvider(chapterId: chapter.id),
    );
    final downloadStatus = downloadManager.value?.status;
    final downloadProgress = downloadManager.value?.progress;

    Widget? downloadIcon;
    if (downloadStatus == DownloadStatus.downloading) {
      downloadIcon = Card(
        child: Padding(
          padding: LayoutConstants.smallEdgeInsets,
          child: SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(
              value: downloadProgress,
            ),
          ),
        ),
      );
    } else if (downloadStatus == DownloadStatus.completed) {
      downloadIcon = Card(
        child: Padding(
          padding: LayoutConstants.smallEdgeInsets,
          child: Icon(
            LucideIcons.download,
            color: Theme.of(context).colorScheme.tertiary,
            size: 16,
          ),
        ),
      );
    }

    void Function()? onDownloadChapterAction;
    void Function()? onRemoveDownloadAction;

    if (downloadStatus == DownloadStatus.initial) {
      onDownloadChapterAction = () {
        ref
            .read(
              chapterConfigProvider(
                chapterId: chapter.id,
              ).notifier,
            )
            .setDownload(true);
      };
    } else if (downloadStatus != .initial) {
      onRemoveDownloadAction = () {
        ref
            .read(
              chapterConfigProvider(
                chapterId: chapter.id,
              ).notifier,
            )
            .setDownload(false);
      };
    }

    return ActionsContextMenu(
      onMarkRead: () async {
        await ref.read(markReadProvider.notifier).markRead();
        ref.invalidate(provider);
      },
      onMarkUnread: () async {
        await ref.read(markReadProvider.notifier).markUnread();
        ref.invalidate(provider);
      },
      onDownloadChapter: onDownloadChapterAction,
      onRemoveDownload: onRemoveDownloadAction,
      child: CoverCard(
        title: state.value.title,
        coverImage: ChapterCoverImage(chapterId: state.value.id),
        progress: state.value.progress,
        downloadStatusIcon: downloadIcon, // Pass the determined icon here
        onTap: () {
          ReaderRoute(
            seriesId: seriesId,
            chapterId: state.value.id,
          ).push(context);
        },
      ),
    );
  }
}
