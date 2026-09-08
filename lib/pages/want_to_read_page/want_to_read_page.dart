import 'package:kover/models/enums/order_by_option.dart';
import 'package:kover/models/enums/sort_direction.dart';
import 'package:kover/widgets/sliver_list_page/sliver_series_page_body.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/riverpod/managers/sync_manager/sync_manager.dart';
import 'package:kover/riverpod/providers/want_to_read.dart';
import 'package:kover/widgets/sliver_list_page/sliver_page_shell.dart';
import 'package:kover/widgets/sliver_list_page/sort_options_menu.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:kover/widgets/util/login_guard.dart';

class WantToReadPage extends StatelessWidget {
  const WantToReadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      extendBody: true,
      body: LoginGuard(child: WantToReadPageContent()),
    );
  }
}

class WantToReadPageContent extends HookConsumerWidget {
  const WantToReadPageContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final controller = useTextEditingController();
    final orderBy = useState(UnorderedSortOption.name);
    final sortDirection = useState(SortDirection.ascending);
    final hideRead = useState(false);
    final series = ref.watch(
      wantToReadListProvider(
        query: controller.text,
        orderBy: orderBy.value,
        direction: sortDirection.value,
        hideRead: hideRead.value,
      ),
    );

    useListenable(controller);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncManagerProvider.notifier).syncLibraries();
    });

    return EntitiesPage(
      title: l.wantToRead,
      filterController: controller,
      appBarActions: [
        UnorderedSortMenu(
          sortDirection: sortDirection.value,
          onSortDirectionChanged: (direction) =>
              sortDirection.value = direction,
          orderBy: orderBy.value,
          onOrderByChanged: (value) => orderBy.value = value,
          hideRead: hideRead.value,
          onHideReadChanged: (value) => hideRead.value = value,
        ),
      ],
      sliver: AsyncSliver(
        asyncValue: series,
        data: (data) => SliverSeriesPageBody(series: data),
      ),
    );
  }
}
