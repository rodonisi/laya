import 'package:kover/models/reading_list_model.dart';
import 'package:kover/widgets/cards/reading_list_card.dart';
import 'package:kover/widgets/lists/list_entries/reading_list_list_entry.dart';
import 'package:kover/widgets/sliver_list_page/sliver_page_shell.dart';
import 'package:material_ui/material_ui.dart';

class SliverReadingListsPageBody extends StatelessWidget {
  final List<ReadingListModel> readingLists;
  const new({super.key, required this.readingLists});

  @override
  Widget build(BuildContext context) {
    return SliverEntitiesPageBody<ReadingListModel>(
      items: readingLists,
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
