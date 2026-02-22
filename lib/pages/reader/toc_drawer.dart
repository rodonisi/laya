import 'package:flutter/material.dart';
import 'package:fluvita/models/book_chapter_model.dart';
import 'package:fluvita/riverpod/providers/book.dart';
import 'package:fluvita/riverpod/providers/reader/reader_navigation.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TocDrawer extends ConsumerWidget {
  final int chapterId;
  final int seriesId;
  const TocDrawer({
    super.key,
    required this.chapterId,
    required this.seriesId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapters = ref.watch(bookChaptersProvider(chapterId: chapterId));

    return Drawer(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: LayoutConstants.mediumEdgeInsets,
            sliver: SliverToBoxAdapter(
              child: Text(
                'Table of Contents',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          AsyncSliver(
            asyncValue: chapters,
            data: (data) => SliverList.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Card.filled(
                  clipBehavior: .hardEdge,
                  margin: const EdgeInsets.symmetric(
                    horizontal: LayoutConstants.mediumPadding,
                    vertical: LayoutConstants.smallerPadding,
                  ),
                  child: TocEntry(
                    seriesId: seriesId,
                    chapterId: chapterId,
                    chapter: data[index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TocEntry extends ConsumerWidget {
  final int chapterId;
  final int seriesId;
  final BookChapterModel chapter;
  final int depth;
  const TocEntry({
    super.key,
    required this.chapterId,
    required this.seriesId,
    required this.chapter,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(
      readerNavigationProvider(seriesId: seriesId, chapterId: chapterId),
    );

    return Column(
      mainAxisSize: .min,
      children: [
        ListTile(
          selected: nav.currentPage == chapter.page,
          contentPadding: depth > 0
              ? EdgeInsetsGeometry.only(
                  left: depth * LayoutConstants.largePadding,
                )
              : null,
          title: Text(chapter.title),
          onTap: () {
            ref
                .read(
                  readerNavigationProvider(
                    chapterId: chapterId,
                    seriesId: seriesId,
                  ).notifier,
                )
                .jumpToPage(chapter.page);
          },
        ),
        ...chapter.children.map<Widget>(
          (child) => TocEntry(
            chapterId: chapterId,
            seriesId: seriesId,
            chapter: child,
            depth: depth + 1,
          ),
        ),
      ],
    );
  }
}
