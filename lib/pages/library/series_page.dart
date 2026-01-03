import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:laya/riverpod/api/series.dart';
import 'package:laya/riverpod/router.dart';

class SeriesPage extends ConsumerWidget {
  final int libraryId;
  const SeriesPage({super.key, required this.libraryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(allSeriesProvider(libraryId));
    return series.when(
      data: (series) => Scaffold(
        appBar: AppBar(
          title: Text('Series in Library $libraryId'),
        ),
        body: ListView.builder(
          itemCount: series.length,
          itemBuilder: (context, index) {
            final s = series[index];
            return ListTile(
              title: Text(s.name),
              subtitle: Text(s.id.toString()),
              onTap: () => ChaptersRoute(libraryId: libraryId, seriesId: s.id)
                  .push(context),
            );
          },
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
