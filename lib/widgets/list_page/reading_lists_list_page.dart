import 'package:kover/models/reading_list_model.dart';
import 'package:kover/widgets/cards/reading_list_card.dart';
import 'package:kover/widgets/list_page/entities_list_page.dart';
import 'package:kover/widgets/lists/list_entries/reading_list_list_entry.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class ReadingListsListPage extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final AsyncValue<List<ReadingListModel>> readingLists;
  final Widget? sortMenu;

  const new({
    super.key,
    required this.title,
    required this.controller,
    required this.readingLists,
    this.sortMenu,
  });

  @override
  Widget build(BuildContext context) {
    return EntitiesListPage(
      title: title,
      filterController: controller,
      items: readingLists,
      sortMenu: sortMenu,
      gridBuilder: (context, readingList) => ReadingListCard(
        key: ValueKey(readingList.id),
        readingListId: readingList.id,
      ),
      listBuilder: (context, readingList) => ReadingListListEntry(
        key: ValueKey(readingList.id),
        readingListId: readingList.id,
      ),
    );
  }
}
