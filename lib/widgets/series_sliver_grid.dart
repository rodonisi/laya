import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/riverpod/router.dart';
import 'package:laya/utils/layout_constants.dart';
import 'package:laya/widgets/cover_image.dart';

class SeriesSliverGrid extends StatelessWidget {
  final List<SeriesModel> series;
  final int childCount;

  const SeriesSliverGrid({
    super.key,
    required this.series,
    required this.childCount,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 5,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
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
        childCount: childCount,
      ),
    );
  }
}
