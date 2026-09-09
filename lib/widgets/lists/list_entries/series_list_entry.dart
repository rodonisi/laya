import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kover/riverpod/providers/router.dart';
import 'package:kover/riverpod/providers/series.dart';
import 'package:kover/utils/constants/kover_icons.dart';
import 'package:kover/widgets/cards/cover_image.dart';
import 'package:kover/widgets/lists/cover_list_entry.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:material_ui/material_ui.dart';

class SeriesListEntry extends ConsumerWidget {
  final int seriesId;

  const new({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(seriesProvider(seriesId: seriesId));
    final progress = ref.watch(seriesProgressProvider(seriesId: seriesId));

    return Async(
      asyncValue: series,
      data: (data) {
        return CoverListEntry(
          title: data.name,
          progress: progress.value,
          cover: SeriesCoverImage(seriesId: seriesId),
          trailing: const Icon(KoverIcons.chevronRight),
          onTap: () {
            SeriesDetailRoute(seriesId: seriesId).push(context);
          },
        );
      },
      loading: () => const CoverListEntryPlaceholder(),
    );
  }
}
