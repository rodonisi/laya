import 'package:flutter/material.dart';
import 'package:fluvita/widgets/chapter_grid.dart';
import 'package:fluvita/pages/library/series_detail_page/series_app_bar.dart';
import 'package:fluvita/widgets/volume_card.dart';
import 'package:fluvita/widgets/adaptive_sliver_grid.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/models/volume_model.dart';
import 'package:fluvita/riverpod/providers/series.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:fluvita/widgets/sliver_bottom_padding.dart';

class SeriesDetailPage extends HookConsumerWidget {
  final int seriesId;

  const SeriesDetailPage({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(seriesDetailProvider(seriesId: seriesId));

    return Scaffold(
      body: Async(
        asyncValue: details,
        data: (detailsData) {
          final tabs = <Widget>[];
          final views = <Widget>[];

          if (detailsData.unreadChapters.isNotEmpty) {
            tabs.add(
              Tab(
                text: 'Unread Chapters (${detailsData.unreadChapters.length})',
              ),
            );
            views.add(
              ChapterGrid(
                seriesId: seriesId,
                chapters: detailsData.unreadChapters,
              ),
            );
          }

          if (detailsData.unreadVolumes.isNotEmpty) {
            tabs.add(
              Tab(
                text: 'Unread Volumes (${detailsData.unreadVolumes.length})',
              ),
            );
            views.add(_VolumeGrid(volumes: detailsData.unreadVolumes));
          }

          if (detailsData.storyline.isNotEmpty) {
            tabs.add(Tab(text: 'Storyline (${detailsData.storyline.length})'));
            views.add(
              ChapterGrid(seriesId: seriesId, chapters: detailsData.storyline),
            );
          }

          if (detailsData.volumes.isNotEmpty) {
            tabs.add(Tab(text: 'Volumes (${detailsData.volumes.length})'));
            views.add(_VolumeGrid(volumes: detailsData.volumes));
          }

          if (detailsData.chapters.isNotEmpty) {
            tabs.add(Tab(text: 'Chapters (${detailsData.chapters.length})'));
            views.add(
              ChapterGrid(seriesId: seriesId, chapters: detailsData.chapters),
            );
          }

          if (detailsData.specials.isNotEmpty) {
            tabs.add(Tab(text: 'Specials (${detailsData.specials.length})'));
            views.add(
              ChapterGrid(seriesId: seriesId, chapters: detailsData.specials),
            );
          }

          if (tabs.isEmpty) {
            return CustomScrollView(
              slivers: [
                SeriesAppBar(
                  seriesId: seriesId,
                ),
                const SliverFillRemaining(
                  child: Center(child: Text('No content available')),
                ),
              ],
            );
          }

          return DefaultTabController(
            length: tabs.length,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                    sliver: SeriesAppBar(
                      seriesId: seriesId,
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
                            handle:
                                NestedScrollView.sliverOverlapAbsorberHandleFor(
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
          );
        },
        loading: () => CustomScrollView(
          slivers: [
            SeriesAppBar(
              seriesId: seriesId,
            ),
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}

class _VolumeGrid extends StatelessWidget {
  final List<VolumeModel> volumes;

  const _VolumeGrid({required this.volumes});

  @override
  Widget build(BuildContext context) {
    return AdaptiveSliverGrid(
      itemCount: volumes.length,
      builder: (context, index) {
        final volume = volumes[index];
        return VolumeCard(volumeId: volume.id);
      },
    );
  }
}
