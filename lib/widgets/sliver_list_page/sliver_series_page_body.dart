import 'package:kover/models/series_model.dart';
import 'package:kover/widgets/cards/series_card.dart';
import 'package:kover/widgets/lists/list_entries/series_list_entry.dart';
import 'package:kover/widgets/sliver_list_page/sliver_page_shell.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class SeriesListPage extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final AsyncValue<List<SeriesModel>> series;
  final Widget? sortMenu;

  const new({
    super.key,
    required this.title,
    required this.controller,
    required this.series,
    this.sortMenu,
  });

  @override
  Widget build(BuildContext context) {
    return EntitiesListPage(
      title: title,
      filterController: controller,
      items: series,
      sortMenu: sortMenu,
      gridBuilder: (context, series) =>
          SeriesCard(key: ValueKey(series.id), seriesId: series.id),
      listBuilder: (context, series) =>
          SeriesListEntry(key: ValueKey(series.id), seriesId: series.id),
    );
  }
}
