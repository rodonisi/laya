import 'package:flutter/material.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/api/library.dart';
import 'package:fluvita/riverpod/api/series.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:fluvita/widgets/series_sliver_grid.dart';
import 'package:fluvita/widgets/sliver_bottom_padding.dart';

class SeriesPage extends ConsumerWidget {
  final int libraryId;
  const SeriesPage({super.key, required this.libraryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lib = ref.watch(libraryProvider(libraryId: libraryId));
    final series = ref.watch(allSeriesProvider(libraryId));
    return Scaffold(
      body: Async(
        asyncValue: lib,
        data: (data) => CustomScrollView(
          slivers: [
            SliverAppBar.large(title: Text(data.name)),
            AsyncSliver(
              asyncValue: series,
              data: (data) => SliverPadding(
                padding: LayoutConstants.smallEdgeInsets,
                sliver: SeriesSliverGrid(
                  series: data,
                ),
              ),
            ),
            SliverBottomPadding(),
          ],
        ),
      ),
    );
  }
}
