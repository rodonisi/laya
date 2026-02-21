import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluvita/models/volume_model.dart';
import 'package:fluvita/riverpod/providers/download.dart';
import 'package:fluvita/riverpod/providers/reader.dart';
import 'package:fluvita/riverpod/providers/volume.dart';
import 'package:fluvita/riverpod/repository/download_repository.dart';
import 'package:fluvita/riverpod/router.dart';
import 'package:fluvita/widgets/actions_menu.dart';
import 'package:fluvita/widgets/cover_card.dart';
import 'package:fluvita/widgets/cover_image.dart';
import 'package:fluvita/widgets/download_status_icon.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class VolumeCard extends HookConsumerWidget {
  const VolumeCard({
    super.key,
    required this.volume,
  });

  final VolumeModel volume;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = volumeProvider(volumeId: volume.id);
    final progress = ref
        .watch(volumeProgressProvider(volumeId: volume.id))
        .value;

    final state = useState(volume);

    ref.listen(provider, (previous, next) {
      if (next.hasValue) {
        // keep the name from the argument model as the volume endpoint may return a different name
        state.value = next.value!.copyWith(name: volume.name);
      }
    });

    useEffect(() {
      state.value = volume;
      return null;
    }, [volume]);

    final markReadProvider = markVolumeReadProvider(
      seriesId: state.value.seriesId,
      volumeId: state.value.id,
    );

    final title = double.tryParse(state.value.name) == null
        ? state.value.name
        : 'Volume ${state.value.name}';

    // Stable sorted list of chapter IDs for the download provider.
    final chapterIds = useMemoized(
      () => ([...state.value.chapters.map((c) => c.id)]..sort()),
      [state.value.chapters],
    );

    final downloadProgress = ref
        .watch(volumeDownloadProgressProvider(volumeId: volume.id))
        .value;

    final isAllDownloaded = downloadProgress == 1.0;
    final isDownloading =
        downloadProgress != null &&
        downloadProgress > 0.0 &&
        downloadProgress < 1.0;
    final downloadRatio = isDownloading ? downloadProgress : null;
    final repo = ref.read(downloadRepositoryProvider);

    void Function()? onDownloadVolume;
    void Function()? onRemoveVolumeDownload;

    if (!isAllDownloaded && !isDownloading) {
      onDownloadVolume = () => repo.downloadVolume(chapterIds: chapterIds);
    } else {
      onRemoveVolumeDownload = () => repo.deleteVolume(volumeId: volume.id);
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
      onDownloadVolume: onDownloadVolume,
      onRemoveVolumeDownload: onRemoveVolumeDownload,
      child: CoverCard(
        title: title,
        coverImage: VolumeCoverImage(volumeId: state.value.id),
        progress: progress,
        downloadStatusIcon: DownloadStatusIcon(
          isDownloaded: isAllDownloaded,
          isDownloading: isDownloading,
          progress: downloadRatio,
        ),
        onRead: () {
          if (state.value.chapters.isNotEmpty) {
            ReaderRoute(
              seriesId: state.value.seriesId,
              chapterId: state.value.chapters.first.id,
            ).push(context);
          }
        },
        onTap: () {
          VolumeDetailRoute(state.value).push(context);
        },
      ),
    );
  }
}
