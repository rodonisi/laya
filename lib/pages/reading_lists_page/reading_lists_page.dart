import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/enums/order_by_option.dart';
import 'package:kover/models/enums/sort_direction.dart';
import 'package:kover/riverpod/managers/sync_manager/sync_manager.dart';
import 'package:kover/riverpod/providers/reading_lists.dart';
import 'package:kover/widgets/sliver_list_page/sort_options_menu.dart';
import 'package:kover/widgets/sliver_list_page/sliver_page_shell.dart';
import 'package:kover/widgets/sliver_list_page/sliver_reading_lists_page_body.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:kover/widgets/util/login_guard.dart';
import 'package:material_ui/material_ui.dart';

class ReadingListsPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      extendBody: true,
      body: LoginGuard(child: ReadingListsPageContent()),
    );
  }
}

class ReadingListsPageContent extends HookConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final controller = useTextEditingController();
    final orderBy = useState(UnorderedSortOption.name);
    final sortDirection = useState(SortDirection.descending);
    final readingLists = ref.watch(
      readingListsProvider(
        query: controller.text,
        orderBy: orderBy.value,
        direction: sortDirection.value,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncManagerProvider.notifier).syncReadingLists();
    });

    return EntitiesPage(
      title: l.readingLists,
      filterController: controller,
      appBarActions: [
        UnorderedSortMenu(
          sortDirection: sortDirection.value,
          onSortDirectionChanged: (direction) =>
              sortDirection.value = direction,
          orderBy: orderBy.value,
          onOrderByChanged: (value) => orderBy.value = value,
        ),
      ],
      sliver: AsyncSliver(
        asyncValue: readingLists,
        data: (data) {
          return SliverReadingListsPageBody(readingLists: data);
        },
      ),
    );
  }
}
