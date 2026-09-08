import 'package:kover/models/collection_model.dart';
import 'package:kover/widgets/cards/collection_card.dart';
import 'package:kover/widgets/lists/list_entries/collection_list_entry.dart';
import 'package:kover/widgets/sliver_list_page/sliver_page_shell.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class CollectionsListPage extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final AsyncValue<List<CollectionModel>> collections;
  final Widget? sortMenu;

  const new({
    super.key,
    required this.title,
    required this.controller,
    required this.collections,
    this.sortMenu,
  });

  @override
  Widget build(BuildContext context) {
    return EntitiesListPage(
      title: title,
      filterController: controller,
      items: collections,
      sortMenu: sortMenu,
      gridBuilder: (context, collection) => CollectionCard(
        key: ValueKey(collection.id),
        collectionId: collection.id,
      ),
      listBuilder: (context, collection) => CollectionListEntry(
        key: ValueKey(collection.id),
        collectionId: collection.id,
      ),
    );
  }
}
