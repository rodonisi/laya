import 'package:flutter/material.dart';
import 'package:fluvita/models/volume_model.dart';
import 'package:fluvita/pages/library/series_detail_page/series_app_bar.dart';
import 'package:fluvita/pages/library/volume_detail_page/volume_app_bar.dart';
import 'package:fluvita/riverpod/providers/volume.dart';
import 'package:fluvita/widgets/chapter_grid.dart';
import 'package:fluvita/widgets/sliver_bottom_padding.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class VolumeDetailPage extends HookConsumerWidget {
  final VolumeModel volume;

  const VolumeDetailPage({
    super.key,
    required this.volume,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume =
        ref
            .watch(volumeProvider(volumeId: this.volume.id))
            .value
            ?.copyWith(name: this.volume.name) ??
        this.volume;

    final tabs = <Widget>[];
    final views = <Widget>[];

    if (volume.chapters.isNotEmpty) {
      tabs.add(Tab(text: 'Chapters (${volume.chapters.length})'));
      views.add(
        ChapterGrid(seriesId: volume.seriesId, chapters: volume.chapters),
      );
    }

    if (tabs.isEmpty) {
      return CustomScrollView(
        slivers: [
          SeriesAppBar(
            seriesId: volume.seriesId,
          ),
          const SliverFillRemaining(
            child: Center(child: Text('No content available')),
          ),
        ],
      );
    }

    return Scaffold(
      body: DefaultTabController(
        length: tabs.length,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
                sliver: VolumeAppBar(
                  volume: volume,
                  bottom: TabBar(
                    isScrollable: true,
                    tabAlignment: .start,
                    tabs: tabs,
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: views.map((view) {
              return Builder(
                builder: (context) {
                  return CustomScrollView(
                    slivers: [
                      SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context,
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(8.0),
                        sliver: view,
                      ),
                      const SliverBottomPadding(),
                    ],
                  );
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
