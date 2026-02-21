import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/riverpod/providers/download.dart';
import 'package:fluvita/riverpod/providers/reader.dart';
import 'package:fluvita/riverpod/providers/series.dart';
import 'package:fluvita/riverpod/providers/want_to_read.dart';
import 'package:fluvita/riverpod/repository/download_repository.dart';
import 'package:fluvita/riverpod/router.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:fluvita/widgets/actions_menu.dart';
import 'package:fluvita/widgets/cover_card.dart';
import 'package:fluvita/widgets/cover_image.dart';
import 'package:fluvita/widgets/download_status_icon.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SeriesCard extends HookConsumerWidget {
  const SeriesCard({
    super.key,
    required this.series,
  });

  final SeriesModel series;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = seriesProvider(seriesId: series.id);
    final progress = ref
        .watch(seriesProgressProvider(seriesId: series.id))
        .value;

    final state = useState(series);

    ref.listen(provider, (previous, next) {
      if (next.hasValue) {
        // keep the name from the argument model as the series endpoint may return a different name
        state.value = next.value!.copyWith(name: series.name);
      }
    });

    useEffect(() {
      state.value = series;
      return null;
    }, [series]);

    final wantToRead = wantToReadProvider(seriesId: state.value.id);
    final isWantToRead = ref.watch(wantToRead).value ?? false;

    final markReadProvider = markSeriesReadProvider(seriesId: state.value.id);

    final downloadProgress = ref
        .watch(seriesDownloadProgressProvider(seriesId: state.value.id))
        .value;

    final isAllDownloaded = downloadProgress != null && downloadProgress >= 1.0;
    final isDownloading =
        !isAllDownloaded && downloadProgress != null && downloadProgress > 0;

    final repo = ref.read(downloadRepositoryProvider);

    void Function()? onDownloadSeries;
    void Function()? onRemoveSeriesDownload;

    if (!isAllDownloaded && !isDownloading) {
      onDownloadSeries = () => repo.downloadSeries(seriesId: state.value.id);
    } else {
      onRemoveSeriesDownload = () =>
          repo.deleteSeries(seriesId: state.value.id);
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
      onAddWantToRead: isWantToRead
          ? null
          : () async {
              await ref.read(wantToRead.notifier).add();
            },
      onRemoveWantToRead: isWantToRead
          ? () async {
              await ref.read(wantToRead.notifier).remove();
            }
          : null,
      onDownloadSeries: onDownloadSeries,
      onRemoveSeriesDownload: onRemoveSeriesDownload,
      child: CoverCard(
        title: state.value.name,
        icon: Icon(
          switch (state.value.format) {
            .epub => LucideIcons.bookText,
            .archive => LucideIcons.fileArchive,
            .unknown => LucideIcons.fileQuestionMark,
          },
          size: LayoutConstants.smallIcon,
        ),
        progress: progress,
        coverImage: SeriesCoverImage(seriesId: state.value.id),
        downloadStatusIcon: DownloadStatusIcon(
          isDownloaded: isAllDownloaded,
          isDownloading: isDownloading,
          progress: downloadProgress,
        ),
        onTap: () {
          SeriesDetailRoute(
            libraryId: state.value.libraryId,
            seriesId: state.value.id,
          ).push(context);
        },
        onRead: () {
          ReaderRoute(
            seriesId: state.value.id,
          ).push(context);
        },
      ),
    );
  }
}
