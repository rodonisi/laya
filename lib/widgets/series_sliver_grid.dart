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
        return GestureDetector(
          onTap: () {
            SeriesDetailRoute(
              libraryId: series.libraryId,
              seriesId: series.id,
            ).push(context);
          },
          child: Card(
            clipBehavior: .antiAlias,
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: SeriesCoverImage(seriesId: series.id),
                      ),
                      Align(
                        alignment: .topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FilledButton.icon(
                            // iconSize: LayoutConstants.mediumIcon,
                            label: Text('Continue'),
                            onPressed: () {
                              ReaderRoute(
                                seriesId: series.id,
                              ).push(context);
                            },
                            icon: FaIcon(FontAwesomeIcons.play),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                LinearProgressIndicator(
                  value: (series.pagesRead / series.pages).clamp(0.0, 1.0),
                ),
                Padding(
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
              ],
            ),
          ),
        );
      },
    );
  }
}
