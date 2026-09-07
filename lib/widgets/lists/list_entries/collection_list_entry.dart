import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kover/riverpod/providers/collections.dart';
import 'package:kover/riverpod/providers/router.dart';
import 'package:kover/utils/constants/kover_icons.dart';
import 'package:kover/widgets/cards/cover_image.dart';
import 'package:kover/widgets/lists/cover_list_entry.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:material_ui/material_ui.dart';

class CollectionListEntry extends ConsumerWidget {
  final int collectionId;

  const new({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collection = ref.watch(
      collectionProvider(collectionId: collectionId),
    );

    return Async(
      asyncValue: collection,
      data: (data) {
        return CoverListEntry(
          title: data.title,
          cover: CollectionCoverImage(collectionId: collectionId),
          trailing: const Icon(KoverIcons.chevronRight),
          onTap: () {
            CollectionSeriesRoute(collectionId: collectionId).go(context);
          },
        );
      },
      loading: () => const CoverListEntryPlaceholder(),
    );
  }
}
