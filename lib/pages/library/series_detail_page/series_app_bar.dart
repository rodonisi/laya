import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/models/series_model.dart';
import 'package:kover/pages/library/series_detail_page/series_info_background.dart';
import 'package:kover/riverpod/managers/download_manager.dart';
import 'package:kover/riverpod/providers/download.dart';
import 'package:kover/riverpod/providers/reader.dart';
import 'package:kover/riverpod/providers/router.dart';
import 'package:kover/riverpod/providers/series.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/actions_menu.dart';
import 'package:kover/widgets/adaptive_sliver_app_bar.dart';
import 'package:kover/widgets/async_value.dart';
import 'package:kover/widgets/cover_card.dart';
import 'package:kover/widgets/cover_image.dart';
import 'package:kover/widgets/info_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SeriesAppBar extends HookConsumerWidget {
  final int seriesId;
  final PreferredSizeWidget? bottom;

  const SeriesAppBar({
    super.key,
    required this.seriesId,
    this.bottom,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(seriesProvider(seriesId: seriesId));
    final downloadProgress =
        ref.watch(seriesDownloadProgressProvider(seriesId: seriesId)).value ??
        0.0;

    return AsyncSliver(
      asyncValue: series,
      data: (data) {
        return AdaptiveSliverAppBar(
          title: data.name,
          bottom: bottom,
          actions: [
            WantToReadToggle(seriesId: data.id),
            ActionsMenuButton(
              onMarkRead: () async {
                await ref
                    .read(
                      markSeriesReadProvider(
                        seriesId: seriesId,
                      ).notifier,
                    )
                    .markRead();
                ref.invalidate(
                  seriesDetailProvider(seriesId: seriesId),
                );
              },
              onMarkUnread: () async {
                await ref
                    .read(
                      markSeriesReadProvider(
                        seriesId: seriesId,
                      ).notifier,
                    )
                    .markUnread();
                ref.invalidate(
                  seriesDetailProvider(seriesId: seriesId),
                );
              },
              onDownload: downloadProgress < 1.0
                  ? () async {
                      await ref
                          .read(downloadManagerProvider.notifier)
                          .enqueueSeries(seriesId);
                    }
                  : null,
              onRemoveDownload: downloadProgress > 0.0
                  ? () async {
                      await ref
                          .read(downloadManagerProvider.notifier)
                          .deleteSeries(seriesId);
                    }
                  : null,
              child: const Icon(LucideIcons.ellipsisVertical),
            ),
          ],
          background: SeriesInfoBackground(
            primaryColor: data.primaryColor,
            secondaryColor: data.secondaryColor,
          ),
          child: _SeriesInfo(seriesId: seriesId),
        );
      },
    );
  }
}

class _SeriesInfo extends ConsumerWidget {
  final int seriesId;
  const _SeriesInfo({
    required this.seriesId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(seriesProvider(seriesId: seriesId));
    return Async(
      asyncValue: series,
      data: (series) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LayoutConstants.largePadding,
        ),
        child: Column(
          spacing: LayoutConstants.largePadding,
          crossAxisAlignment: .start,
          mainAxisAlignment: .start,
          mainAxisSize: .min,
          children: [
            const SizedBox.square(dimension: kToolbarHeight),
            Text(
              series.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Row(
              spacing: LayoutConstants.largePadding,
              children: [
                SizedBox(
                  height: 250,
                  child: _Cover(seriesId: series.id),
                ),
                Expanded(
                  child: _Metadata(
                    series: series,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metadata extends ConsumerWidget {
  final SeriesModel series;
  const _Metadata({
    required this.series,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadata = ref.watch(seriesMetadataProvider(seriesId: series.id));
    return Async(
      asyncValue: metadata,
      data: (metadata) => Column(
        crossAxisAlignment: .start,
        spacing: LayoutConstants.largePadding,
        children: [
          Wrap(
            spacing: LayoutConstants.mediumPadding,
            runSpacing: LayoutConstants.mediumPadding,
            alignment: .spaceBetween,
            children: [
              if ((series.wordCount ?? 0) > 0)
                WordCount(wordCount: series.wordCount!),
              Pages(pages: series.pages),
              RemainingHours(
                hours: series.avgHoursToRead,
              ),
              if (metadata.releaseYear != null)
                ReleaseYear(
                  releaseYear: metadata.releaseYear!,
                ),
            ],
          ),
          Wrap(
            spacing: LayoutConstants.mediumPadding,
            runSpacing: LayoutConstants.mediumPadding,
            alignment: .spaceBetween,
            children: [
              LimitedList(
                title: 'Writers',
                items: metadata.writers.map((w) => w.name).toList(),
              ),
              LimitedList(
                title: 'Genres',
                items: metadata.genres.map((a) => a.name).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cover extends ConsumerWidget {
  final int seriesId;

  const _Cover({
    required this.seriesId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final continuePoint = ref.watch(
      continuePointStreamProvider(seriesId: seriesId),
    );
    final canRead = ref.watch(canReadSeriesProvider(seriesId)).value ?? false;
    final progress =
        ref
            .watch(
              continuePointProgressProvider(seriesId: seriesId),
            )
            .value ??
        0.0;

    return AspectRatio(
      aspectRatio: LayoutConstants.chapterCardAspectRatio,
      child: Async(
        asyncValue: continuePoint,
        data: (data) => CoverCard(
          title: data.title,
          actionLabel: 'Continue',
          actionDisabled: !canRead,
          progress: progress,
          coverImage: SeriesCoverImage(
            seriesId: seriesId,
            fit: BoxFit.cover,
          ),
          onActionTap: () {
            continuePoint.whenData((chapter) {
              ReaderRoute(
                seriesId: seriesId,
                chapterId: chapter.id,
              ).push(context);
            });
          },
        ),
      ),
    );
  }
}
