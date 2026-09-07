import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/enums/order_by_option.dart';
import 'package:kover/models/enums/sort_direction.dart';
import 'package:kover/riverpod/managers/sync_manager/sync_manager.dart';
import 'package:kover/riverpod/providers/collections.dart';
import 'package:kover/widgets/sliver_list_page/series_sort_options_menu.dart';
import 'package:kover/widgets/sliver_list_page/sliver_collections_page_body.dart';
import 'package:kover/widgets/sliver_list_page/sliver_page_shell.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:kover/widgets/util/login_guard.dart';
import 'package:material_ui/material_ui.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      extendBody: true,
      body: LoginGuard(child: CollectionsPageContent()),
    );
  }
}

class CollectionsPageContent extends HookConsumerWidget {
  const CollectionsPageContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final orderBy = useState(UnorderedSortOption.name);
    final sortDirection = useState(SortDirection.ascending);
    final controller = useTextEditingController();
    final collections = ref.watch(
      collectionsProvider(
        query: controller.text,
        orderBy: orderBy.value,
        direction: sortDirection.value,
      ),
    );

    useListenable(controller);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncManagerProvider.notifier).syncCollections();
    });

    return EntitiesPage(
      title: l.collections,
      filterController: controller,
      appBarActions: [
        SeriesSortOptionsMenu(
          sortDirection: sortDirection.value,
          onSortDirectionChanged: (SortDirection newDirection) {
            sortDirection.value = newDirection;
          },
          orderBy: orderBy.value,
          onOrderByChanged: (UnorderedSortOption newOrderBy) {
            orderBy.value = newOrderBy;
          },
        ),
      ],
      sliver: AsyncSliver(
        asyncValue: collections,
        data: (data) {
          return SliverCollectionsPageBody(collections: data);
        },
      ),
    );
  }
}
