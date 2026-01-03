import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:laya/riverpod/api/series.dart';
import 'package:laya/riverpod/router.dart';

class ChaptersPage extends ConsumerWidget {
  final int seriesId;
  const ChaptersPage({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(seriesDetailProvider(seriesId));

    return series.when(
      data: (series) {
        final chapters = (series.chapters ?? []).map(
          (c) => ListTile(
            title: Text(c.title ?? ''),
            subtitle: Text(c.titleName ?? ''),
            onTap: () => ReaderRoute(seriesId: seriesId).push(context),
          ),
        );
        final volumes = (series.volumes ?? []).map(
          (v) => ListTile(
            title: Text(v.name ?? ''),
            onTap: () => ReaderRoute(seriesId: seriesId).push(context),
          ),
        );
        final specials = (series.specials ?? []).map(
          (s) => ListTile(
            title: Text(s.title ?? ''),
            subtitle: Text(s.titleName ?? ''),
            onTap: () => ReaderRoute(seriesId: seriesId).push(context),
          ),
        );

        final tiles = [
          ...chapters,
          ...volumes,
          ...specials,
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text('Chapters in series $seriesId'),
          ),
          body: ListView.builder(
            itemCount: tiles.length,
            itemBuilder: (context, index) {
              return tiles[index];
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
