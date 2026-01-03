import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/riverpod/router.dart';
import 'package:laya/utils/layout_constants.dart';
import 'package:laya/widgets/cover_image.dart';

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
        series.when(
          data: (data) {
            return SliverPadding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: LayoutConstants.mediumPadding,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 5,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final series = data[index];
                    return Card(
                      child: Column(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CoverImage(seriesId: series.id),
                                ),
                                Align(
                                  child: IconButton.filled(
                                    iconSize: LayoutConstants.mediumIcon,
                                    onPressed: () {
                                      ReaderRoute(
                                        seriesId: series.id,
                                      ).push(context);
                                    },
                                    icon: FaIcon(FontAwesomeIcons.book),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Padding(
                              padding: LayoutConstants.smallEdgeInsets,
                              child: Row(
                                mainAxisSize: .min,
                                spacing: LayoutConstants.smallPadding,
                                children: [
                                  Icon(
                                    switch (series.format) {
                                      .epub => FontAwesomeIcons.book,
                                      .cbz => FontAwesomeIcons.fileZipper,
                                      .unknown => FontAwesomeIcons.question,
                                    },
                                    size: LayoutConstants.smallIcon,
                                  ),
                                  Expanded(
                                    child: Text(
                                      series.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: toShow,
                ),
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => SliverToBoxAdapter(
            child: Center(child: Text('Error: $error')),
          ),
        ),
      ],
    );
  }
}
