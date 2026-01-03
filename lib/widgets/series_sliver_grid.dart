import 'package:flutter/material.dart';
import 'package:fluvita/widgets/adaptive_sliver_grid.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/riverpod/router.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:fluvita/widgets/cover_image.dart';

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
        return Card(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: SeriesCoverImage(seriesId: series.id),
                    ),
                    Align(
                      child: IconButton.filled(
                        iconSize: LayoutConstants.mediumIcon,
                        onPressed: () {
                          ReaderRoute(
                            seriesId: series.id,
                          ).push(context);
                        },
                        icon: FaIcon(FontAwesomeIcons.book),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  SeriesDetailRoute(
                    libraryId: series.libraryId,
                    seriesId: series.id,
                  ).push(context);
                },
                child: Padding(
                  padding: LayoutConstants.smallEdgeInsets,
                  child: Row(
                    mainAxisSize: .min,
                    spacing: LayoutConstants.smallPadding,
                    children: [
                      Icon(
                        switch (series.format) {
                          .epub => FontAwesomeIcons.book,
                          .cbz => FontAwesomeIcons.fileZipper,
                          .unknown => FontAwesomeIcons.question,
                        },
                        size: LayoutConstants.smallIcon,
                      ),
                      Expanded(
                        child: Text(
                          series.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
