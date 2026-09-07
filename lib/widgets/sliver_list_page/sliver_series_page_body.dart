import 'package:kover/models/series_model.dart';
import 'package:kover/widgets/cards/series_card.dart';
import 'package:kover/widgets/lists/list_entries/series_list_entry.dart';
import 'package:kover/widgets/sliver_list_page/sliver_page_shell.dart';
import 'package:material_ui/material_ui.dart';

class SliverSeriesPageBody extends StatelessWidget {
  final List<SeriesModel> series;
  const new({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    return SliverEntitiesPageBody<SeriesModel>(
      items: series,
      gridBuilder: (context, series) =>
          SeriesCard(key: ValueKey(series.id), seriesId: series.id),
      listBuilder: (context, series) =>
          SeriesListEntry(key: ValueKey(series.id), seriesId: series.id),
    );
  }
}
