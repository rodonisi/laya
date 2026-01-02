import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:laya/api/export.dart';
import 'package:laya/riverpod/api.dart';
import 'package:laya/utils/layout_constants.dart';
import 'package:laya/widgets/async_value.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: true,

      body: CustomScrollView(
        slivers: [
          OnDeck(),
          RecentlyAdded(),
        ],
      ),
    );
  }
}

class OnDeck extends ConsumerWidget {
  const OnDeck({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onDeck = ref.watch(onDeckProvider);

    return CollapsibleSection(title: 'On Deck', series: onDeck);
  }
}

class RecentlyAdded extends ConsumerWidget {
  const RecentlyAdded({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(recentlyAddedProvider);

    return CollapsibleSection(title: 'Recently Added', series: series);
  }
}

class CollapsibleSection extends HookConsumerWidget {
  final String title;
  final AsyncValue<List<SeriesDto>> series;

  const CollapsibleSection({
    super.key,
    required this.title,
    required this.series,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAll = useState(false);

    final collapsedCount = 3;
    final total = series.value?.length ?? 0;
    final toShow = showAll.value ? total : collapsedCount;

    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(
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
          Async(
            asyncValue: series,
            data: (data) {
              return GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: toShow,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2 / 3,
                ),
                itemBuilder: (context, index) {
                  final series = data[index];
                  return Card(
                    child: Column(
                      children: [
                        Expanded(
                          child: CoverImage(seriesId: series.id),
                        ),
                        Text(
                          series.name ?? 'Untitled',
                          overflow: .ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class CoverImage extends ConsumerWidget {
  final int seriesId;
  const CoverImage({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Async(
      asyncValue: ref.watch(coverImageProvider(seriesId: seriesId)),
      data: (imageData) => ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.memory(
          imageData,
          fit: BoxFit.cover,
          height: 150,
          width: double.infinity,
        ),
      ),
    );
  }
}
