import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:laya/models/chapter_model.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/models/volume_model.dart';
import 'package:laya/riverpod/api/image.dart';
import 'package:laya/riverpod/api/series.dart';
import 'package:laya/riverpod/router.dart';
import 'package:laya/widgets/async_value.dart';
import 'package:laya/widgets/cover_image.dart';
import 'package:laya/widgets/sliver_bottom_padding.dart';

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
        return SliverAppBar(
          expandedHeight: 340,
          pinned: true,
          forceElevated: forceElevated,
          bottom: bottom,
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              final settings = context
                  .dependOnInheritedWidgetOfExactType<
                    FlexibleSpaceBarSettings
                  >();
              final deltaExtent = settings != null
                  ? settings.maxExtent - settings.minExtent
                  : 1.0;
              final currentExtent = settings != null
                  ? settings.currentExtent
                  : constraints.maxHeight;
              final minExtent = settings != null
                  ? settings.minExtent
                  : kToolbarHeight;
              final t = (1.0 - (currentExtent - minExtent) / deltaExtent).clamp(
                0.0,
                1.0,
              );

              final expandedHeight = 200.0;
              final collapsedHeight = 60.0;
              final currentHeight = lerpDouble(
                expandedHeight,
                collapsedHeight,
                t,
              )!;

              final expandedWidth = expandedHeight * (2 / 3);
              final collapsedWidth = collapsedHeight * (2 / 3);
              final currentWidth = lerpDouble(
                expandedWidth,
                collapsedWidth,
                t,
              )!;

              final topPadding = MediaQuery.paddingOf(context).top;
              final expandedTop = kToolbarHeight + 22.0;
              final collapsedTop =
                  topPadding + (kToolbarHeight - collapsedHeight) / 2;
              final currentTop = lerpDouble(expandedTop, collapsedTop, t)!;

              final maxWidth = constraints.maxWidth;
              final expandedLeft = (maxWidth - expandedWidth) / 2;
              final collapsedLeft = maxWidth - 16 - currentWidth;
              final currentLeft = lerpDouble(expandedLeft, collapsedLeft, t)!;

              return Stack(
                fit: StackFit.expand,
                children: [
                  FlexibleSpaceBar(
                    titlePadding: const EdgeInsetsDirectional.only(
                      start: 16,
                      end: 16,
                      bottom: 16 + 46,
                    ),
                    centerTitle: true,
                    title: Text(
                      data.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Async(
                          asyncValue: cover,
                          data: (data) => ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: 10,
                              sigmaY: 10,
                            ),
                            child: Image.memory(
                              data,
                              fit: BoxFit.cover,
                              color: Colors.black54,
                              colorBlendMode: BlendMode.darken,
                            ),
                          ),
                          loading: () => const SizedBox(),
                          error: (_, _) => const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: currentTop,
                    left: currentLeft,
                    width: currentWidth,
                    height: currentHeight,
                    child: SeriesCoverImage(
                      seriesId: seriesId,
                      borderRadius: BorderRadius.circular(
                        lerpDouble(8.0, 4.0, t)!,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
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
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
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
      }, childCount: volumes.length),
    );
  }
}

class _ChapterGrid extends StatelessWidget {
  final int seriesId;
  final List<ChapterModel> chapters;

  const _ChapterGrid({required this.seriesId, required this.chapters});

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
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
      }, childCount: chapters.length),
    );
  }
}
