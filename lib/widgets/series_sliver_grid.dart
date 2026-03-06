import 'package:flutter/material.dart';
import 'package:fluvita/widgets/adaptive_sliver_grid.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/widgets/series_card.dart';

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
        return SeriesCard(seriesId: series.id);
      },
    );
  }
}
