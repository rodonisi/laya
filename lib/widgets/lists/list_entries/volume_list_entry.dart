import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kover/riverpod/providers/router.dart';
import 'package:kover/riverpod/providers/volume.dart';
import 'package:kover/utils/constants/kover_icons.dart';
import 'package:kover/widgets/cards/cover_image.dart';
import 'package:kover/widgets/lists/cover_list_entry.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:material_ui/material_ui.dart';

class VolumeListEntry extends ConsumerWidget {
  final int volumeId;

  const new({super.key, required this.volumeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(volumeProvider(volumeId: volumeId));
    final progress = ref.watch(volumeProgressProvider(volumeId: volumeId));

    return Async(
      asyncValue: volume,
      data: (data) {
        return CoverListEntry(
          title: data.name,
          progress: progress.value,
          cover: VolumeCoverImage(volumeId: volumeId),
          trailing: const Icon(KoverIcons.chevronRight),
          onTap: () {
            VolumeDetailRoute(
              seriesId: data.seriesId,
              volumeId: volumeId,
            ).push(context);
          },
        );
      },
      loading: () => const CoverListEntryPlaceholder(),
    );
  }
}
