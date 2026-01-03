import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/widgets/async_value.dart';
import 'package:laya/widgets/series_sliver_grid.dart';
import 'package:laya/utils/layout_constants.dart';

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

    final collapsedCount = 2;
    final total = series.value?.length ?? 0;
    final toShow = showAll.value ? total : collapsedCount;

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: LayoutConstants.mediumEdgeInsets,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (total > collapsedCount)
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
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: LayoutConstants.mediumPadding,
              ),
              sliver: SeriesSliverGrid(series: data, childCount: toShow),
            );
          },
        ),
      ],
    );
  }
}
