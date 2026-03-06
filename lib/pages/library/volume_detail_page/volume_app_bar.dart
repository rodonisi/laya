import 'package:flutter/material.dart';
import 'package:fluvita/models/volume_model.dart';
import 'package:fluvita/pages/library/series_detail_page/series_info_background.dart';
import 'package:fluvita/riverpod/providers/reader.dart';
import 'package:fluvita/riverpod/providers/volume.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:fluvita/widgets/actions_menu.dart';
import 'package:fluvita/widgets/adaptive_sliver_app_bar.dart';
import 'package:fluvita/widgets/cover_card.dart';
import 'package:fluvita/widgets/cover_image.dart';
import 'package:fluvita/widgets/info_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class VolumeAppBar extends ConsumerWidget {
  final VolumeModel volume;
  final PreferredSizeWidget? bottom;

  const VolumeAppBar({
    super.key,
    required this.volume,
    this.bottom,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveSliverAppBar(
      title: volume.name,
      bottom: bottom,
      background: SeriesInfoBackground(
        primaryColor: volume.primaryColor,
        secondaryColor: volume.secondaryColor,
      ),
      actions: [
        ActionsMenuButton(
          child: const Icon(LucideIcons.ellipsisVertical),
          onMarkRead: () async {
            await ref
                .read(
                  markVolumeReadProvider(
                    volumeId: volume.id,
                  ).notifier,
                )
                .markRead();
            ref.invalidate(volumeProvider(volumeId: volume.id));
          },
          onMarkUnread: () async {
            await ref
                .read(
                  markVolumeReadProvider(
                    volumeId: volume.id,
                  ).notifier,
                )
                .markUnread();
            ref.invalidate(volumeProvider(volumeId: volume.id));
          },
        ),
      ],
      child: _VolumeInfo(volume: volume),
    );
  }
}

class _VolumeInfo extends ConsumerWidget {
  final VolumeModel volume;

  const _VolumeInfo({required this.volume});

  Null get seriesId => null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
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
            volume.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Row(
            spacing: LayoutConstants.largePadding,
            children: [
              SizedBox(
                height: 250,
                child: _Cover(volume: volume),
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
                        if ((volume.wordCount ?? 0) > 0)
                          WordCount(wordCount: volume.wordCount!),
                        Pages(pages: volume.pages),
                        RemainingHours(
                          hours: volume.avgHoursToRead ?? 0,
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
    );
  }
}

class _Cover extends ConsumerWidget {
  final VolumeModel volume;

  const _Cover({
    required this.volume,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref
        .watch(volumeProgressProvider(volumeId: volume.id))
        .value;

    return AspectRatio(
      aspectRatio: LayoutConstants.coverAspectRatio,
      child: CoverCard(
        progress: progress,
        coverImage: VolumeCoverImage(
          volumeId: volume.id,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
