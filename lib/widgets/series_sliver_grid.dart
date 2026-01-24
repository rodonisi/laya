import 'package:flutter/material.dart';
import 'package:fluvita/widgets/adaptive_sliver_grid.dart';
import 'package:fluvita/widgets/chapter_card.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/riverpod/router.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:fluvita/widgets/cover_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SeriesSliverGrid extends StatelessWidget {
  final List<SeriesModel> series;
  final int? rowCount;

  const SeriesSliverGrid({
    super.key,
    required this.series,
    this.rowCount,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveSliverGrid(
      itemCount: series.length,
      rowCount: rowCount,
      builder: (context, index) {
        final series = this.series[index];
        return ChapterCard(
          title: series.name,
          icon: Icon(
            switch (series.format) {
              .epub => LucideIcons.bookText,
              .cbz => LucideIcons.fileArchive,
              .unknown => LucideIcons.fileQuestionMark,
            },
            size: LayoutConstants.smallIcon,
          ),
          progress: series.pagesRead / series.pages,
          coverImage: SeriesCoverImage(seriesId: series.id),
          onTap: () {
            SeriesDetailRoute(
              libraryId: series.libraryId,
              seriesId: series.id,
            ).push(context);
          },
          onRead: () {
            ReaderRoute(
              seriesId: series.id,
            ).push(context);
          },
        );
      },
    );
  }
}
