import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/enums/order_by_option.dart';
import 'package:kover/models/enums/sort_direction.dart';
import 'package:kover/riverpod/providers/series.dart';
import 'package:kover/widgets/sliver_list_page/series_sort_options_menu.dart';
import 'package:kover/widgets/sliver_list_page/sliver_page_shell.dart';
import 'package:kover/widgets/sliver_list_page/sliver_series_page_body.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:kover/widgets/util/login_guard.dart';
import 'package:material_ui/material_ui.dart';

class RecentlyUpdatedPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      extendBody: true,
      body: LoginGuard(
        child: _RecentlyUpdatedPageContent(),
      ),
    );
  }
}

class _RecentlyUpdatedPageContent extends HookConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final sortDirection = useState(SortDirection.descending);
    final orderBy = useState(UnorderedSortOption.dateUpdated);
    final hideRead = useState(false);
    final controller = useTextEditingController();

    useListenable(controller);

    final series = ref.watch(
      recentlyUpdatedProvider(
        query: controller.text,
        direction: sortDirection.value,
        orderBy: orderBy.value,
        hideRead: hideRead.value,
      ),
    );

    return EntitiesPage(
      title: l.recentlyUpdated,
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
          hideRead: hideRead.value,
          onHideReadChanged: (bool newHideRead) {
            hideRead.value = newHideRead;
          },
        ),
      ],
      sliver: AsyncSliver(
        asyncValue: series,
        data: (data) => SliverSeriesPageBody(series: data),
      ),
    );
  }
}
