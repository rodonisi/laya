import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluvita/models/chapter_model.dart';
import 'package:fluvita/riverpod/providers/chapter.dart';
import 'package:fluvita/riverpod/providers/download.dart';
import 'package:fluvita/riverpod/providers/reader.dart';
import 'package:fluvita/riverpod/repository/download_repository.dart';
import 'package:fluvita/riverpod/router.dart';
import 'package:fluvita/widgets/actions_menu.dart';
import 'package:fluvita/widgets/cover_card.dart';
import 'package:fluvita/widgets/cover_image.dart';
import 'package:fluvita/widgets/download_status_icon.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    final progress = ref
        .watch(chapterProgressProvider(chapterId: chapter.id))
        .value;

    final state = useState(chapter);

    ref.listen(provider, (previous, next) {
      if (next.hasValue) {
        // Keep the title from the argument model as the chapter endpoint may
        // return a different title.
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

    final isDownloaded = ref
        .watch(chapterDownloadedProvider(chapterId: chapter.id))
        .value ??
        false;
    final downloadedPages = ref
        .watch(chapterDownloadedPageCountProvider(chapterId: chapter.id))
        .value ??
        0;

    final totalPages = state.value.pages;
    final isDownloading = !isDownloaded && downloadedPages > 0;
    final downloadProgress =
        (totalPages > 0 && isDownloading) ? downloadedPages / totalPages : null;

    final repo = ref.read(downloadRepositoryProvider);

    void Function()? onDownloadChapterAction;
    void Function()? onRemoveDownloadAction;

    if (!isDownloaded && !isDownloading) {
      onDownloadChapterAction = () => repo.downloadChapter(
        chapterId: chapter.id,
      );
    } else {
      onRemoveDownloadAction = () => repo.deleteChapter(
        chapterId: chapter.id,
      );
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
        progress: progress,
        downloadStatusIcon: DownloadStatusIcon(
          isDownloaded: isDownloaded,
          isDownloading: isDownloading,
          progress: downloadProgress,
        ),
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
