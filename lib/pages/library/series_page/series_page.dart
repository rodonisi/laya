import 'package:flutter/material.dart';
import 'package:fluvita/riverpod/api/library.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/api/series.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:fluvita/widgets/series_sliver_grid.dart';
import 'package:fluvita/widgets/sliver_bottom_padding.dart';

class AllSeriesPage extends StatelessWidget {
  const AllSeriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SeriesPage(title: 'All Series');
  }
}

class LibrarySeriesPage extends ConsumerWidget {
  final int libraryId;

  const LibrarySeriesPage({
    super.key,
    required this.libraryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider(libraryId: libraryId));
    return Async(
      asyncValue: library,
      data: (data) {
        return SeriesPage(
          title: data.name,
          libraryId: data.id,
        );
      },
    );
  }
}

class SeriesPage extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final int? libraryId;
  const SeriesPage({
    super.key,
    required this.title,
    this.subtitle,
    this.libraryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(allSeriesProvider(libraryId: libraryId));
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: Text(title)),
          AsyncSliver(
            asyncValue: series,
            data: (data) => SliverPadding(
              padding: LayoutConstants.smallEdgeInsets,
              sliver: SeriesSliverGrid(
                series: data,
              ),
            ),
          ),
          const SliverBottomPadding(),
        ],
      ),
    );
  }
}
