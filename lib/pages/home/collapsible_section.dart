import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:fluvita/widgets/series_sliver_grid.dart';
import 'package:fluvita/utils/layout_constants.dart';

class CollapsibleSection extends HookConsumerWidget {
  final String title;
  final AsyncValue<List<SeriesModel>> series;

  const CollapsibleSection({
    super.key,
    required this.title,
    required this.series,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAll = useState(false);

    final total = series.value?.length ?? 0;
    final toShow = showAll.value ? total : 1;

    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: LayoutConstants.smallEdgeInsets,
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                TextButton(
                  onPressed: () {
                    showAll.value = !showAll.value;
                  },
                  child: Text(showAll.value ? 'Show Less' : 'Show All'),
                ),
              ],
            ),
          ),
        ),
        AsyncSliver(
          asyncValue: series,
          data: (data) {
            return SliverPadding(
              padding: const EdgeInsetsGeometry.symmetric(
                horizontal: LayoutConstants.smallPadding,
              ),
              sliver: SeriesSliverGrid(series: data, rowCount: toShow),
            );
          },
        ),
      ],
    );
  }
}
