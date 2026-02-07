import 'package:flutter/material.dart';
import 'package:fluvita/models/volume_model.dart';
import 'package:fluvita/riverpod/api/reader.dart';
import 'package:fluvita/riverpod/api/volume.dart';
import 'package:fluvita/riverpod/router.dart';
import 'package:fluvita/widgets/actions_menu.dart';
import 'package:fluvita/widgets/cover_card.dart';
import 'package:fluvita/widgets/cover_image.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class VolumeCard extends ConsumerWidget {
  const VolumeCard({
    super.key,
    required this.volume,
  });

  final VolumeModel volume;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = volumeProvider(volumeId: this.volume.id);

    // keep the name from the argument model as the volume endpoint may return a different name
    final volume =
        ref.watch(provider).value?.copyWith(name: this.volume.name) ??
        this.volume;

    final markReadProvider = markVolumeReadProvider(
      seriesId: volume.seriesId,
      volumeId: volume.id,
    );

    final title = double.tryParse(volume.name) == null
        ? volume.name
        : 'Volume ${volume.name}';

    return ActionsContextMenu(
      onMarkRead: () async {
        await ref.read(markReadProvider.notifier).markRead();
        ref.invalidate(provider);
      },
      onMarkUnread: () async {
        await ref.read(markReadProvider.notifier).markUnread();
        ref.invalidate(provider);
      },
      child: CoverCard(
        title: title,
        coverImage: VolumeCoverImage(volumeId: volume.id),
        progress: volume.pagesRead / volume.pages,
        onRead: () {
          if (volume.chapters.isNotEmpty) {
            ReaderRoute(
              seriesId: volume.seriesId,
              chapterId: volume.chapters.first.id,
            ).push(context);
          }
        },
        onTap: () {
          VolumeDetailRoute(volume).push(context);
        },
      ),
    );
  }
}
