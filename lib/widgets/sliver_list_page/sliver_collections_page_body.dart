import 'package:kover/models/collection_model.dart';
import 'package:kover/widgets/cards/collection_card.dart';
import 'package:kover/widgets/lists/list_entries/collection_list_entry.dart';
import 'package:kover/widgets/sliver_list_page/sliver_page_shell.dart';
import 'package:material_ui/material_ui.dart';

class SliverCollectionsPageBody extends StatelessWidget {
  final List<CollectionModel> collections;
  const new({super.key, required this.collections});

  @override
  Widget build(BuildContext context) {
    return SliverEntitiesPageBody<CollectionModel>(
      items: collections,
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
