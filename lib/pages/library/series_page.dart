import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:laya/riverpod/api/library.dart';
import 'package:laya/riverpod/api/series.dart';
import 'package:laya/widgets/async_value.dart';
import 'package:laya/widgets/series_sliver_grid.dart';
import 'package:laya/widgets/sliver_bottom_padding.dart';

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
              data: (data) => SeriesSliverGrid(
                series: data,
                childCount: data.length,
              ),
            ),
            SliverBottomPadding(),
          ],
        ),
      ),
    );
  }
}
