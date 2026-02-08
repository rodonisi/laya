import 'package:flutter/material.dart';
import 'package:fluvita/pages/library/series_detail_page/series_info_background.dart';
import 'package:fluvita/riverpod/api/reader.dart';
import 'package:fluvita/riverpod/router.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:fluvita/widgets/actions_menu.dart';
import 'package:fluvita/widgets/adaptive_sliver_app_bar.dart';
import 'package:fluvita/riverpod/api/series.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:fluvita/widgets/cover_card.dart';
import 'package:fluvita/widgets/cover_image.dart';
import 'package:fluvita/widgets/info_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

    return AsyncSliver(
      asyncValue: series,
      data: (data) {
        return AdaptiveSliverAppBar(
          title: data.name,
          bottom: bottom,
          actions: [
            WantToReadToggle(seriesId: data.id),
            ActionsMenuButton(
              child: const Icon(LucideIcons.ellipsisVertical),
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
    final metadata = ref.watch(seriesMetadataProvider(seriesId: seriesId));
    return Async(
      asyncValue: metadata,
      data: (metadata) => Async(
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
                    child: Column(
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
                              items: metadata.writers
                                  .map((w) => w.name)
                                  .toList(),
                            ),
                            LimitedList(
                              title: 'Genres',
                              items: metadata.genres
                                  .map((a) => a.name)
                                  .toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
    final continuePoint = ref.watch(continuePointProvider(seriesId: seriesId));
    return AspectRatio(
      aspectRatio: LayoutConstants.chapterCardAspectRatio,
      child: Async(
        asyncValue: continuePoint,
        data: (data) => CoverCard(
          title: data.title,
          actionLabel: 'Continue',
          progress: data.progress,
          coverImage: SeriesCoverImage(
            seriesId: seriesId,
            fit: BoxFit.cover,
          ),
          onRead: () {
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
