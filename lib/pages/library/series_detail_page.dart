import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluvita/widgets/adaptive_sliver_grid.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/models/chapter_model.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/models/volume_model.dart';
import 'package:fluvita/riverpod/api/image.dart';
import 'package:fluvita/riverpod/api/series.dart';
import 'package:fluvita/riverpod/router.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:fluvita/widgets/cover_image.dart';
import 'package:fluvita/widgets/sliver_bottom_padding.dart';

class SeriesDetailPage extends ConsumerWidget {
  final int seriesId;

  const SeriesDetailPage({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(seriesProvider(seriesId: seriesId));
    final details = ref.watch(seriesDetailProvider(seriesId: seriesId));
    final cover = ref.watch(seriesCoverProvider(seriesId: seriesId));

    return Scaffold(
      body: Async(
        asyncValue: details,
        data: (detailsData) {
          final tabs = <Widget>[];
          final views = <Widget>[];

          if (detailsData.volumes.isNotEmpty) {
            tabs.add(const Tab(text: 'Volumes'));
            views.add(_VolumeGrid(volumes: detailsData.volumes));
          }

          if (detailsData.chapters.isNotEmpty) {
            tabs.add(const Tab(text: 'Chapters'));
            views.add(
              _ChapterGrid(seriesId: seriesId, chapters: detailsData.chapters),
            );
          }

          if (detailsData.specials.isNotEmpty) {
            tabs.add(const Tab(text: 'Specials'));
            views.add(
              _ChapterGrid(seriesId: seriesId, chapters: detailsData.specials),
            );
          }

          if (tabs.isEmpty) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(series, cover, null),
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
                    sliver: _buildAppBar(
                      series,
                      cover,
                      TabBar(tabs: tabs),
                      forceElevated: innerBoxIsScrolled,
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
                          SliverBottomPadding(),
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
            _buildAppBar(series, cover, null),
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(
    AsyncValue<SeriesModel> series,
    AsyncValue<Uint8List> cover,
    PreferredSizeWidget? bottom, {
    bool forceElevated = false,
  }) {
    return AsyncSliver(
      asyncValue: series,
      data: (data) {
        return SliverAppBar.large(
          forceElevated: forceElevated,
          title: Text(data.name),
          bottom: bottom,
        );
      },
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
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              if (volume.chapters.isNotEmpty) {
                ReaderRoute(
                  seriesId: volume.seriesId,
                  chapterId: volume.chapters.first.id,
                ).push(context);
              }
            },
            child: Column(
              children: [
                Expanded(
                  child: VolumeCoverImage(
                    volumeId: volume.id,
                    width: double.infinity,
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    volume.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChapterGrid extends StatelessWidget {
  final int seriesId;
  final List<ChapterModel> chapters;

  const _ChapterGrid({required this.seriesId, required this.chapters});

  @override
  Widget build(BuildContext context) {
    return AdaptiveSliverGrid(
      itemCount: chapters.length,
      builder: (context, index) {
        final chapter = chapters[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              ReaderRoute(
                seriesId: seriesId,
                chapterId: chapter.id,
              ).push(context);
            },
            child: Column(
              children: [
                Expanded(
                  child: ChapterCoverImage(
                    chapterId: chapter.id,
                    width: double.infinity,
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    chapter.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
