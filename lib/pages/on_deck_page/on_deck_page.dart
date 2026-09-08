import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/enums/order_by_option.dart';
import 'package:kover/models/enums/sort_direction.dart';
import 'package:kover/riverpod/providers/series.dart';
import 'package:kover/widgets/sliver_list_page/sliver_page_shell.dart';
import 'package:kover/widgets/sliver_list_page/sliver_series_page_body.dart';
import 'package:kover/widgets/sliver_list_page/sort_options_menu.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:kover/widgets/util/login_guard.dart';
import 'package:material_ui/material_ui.dart';

class OnDeckPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      extendBody: true,
      body: LoginGuard(
        child: _OnDeckPageContent(),
      ),
    );
  }
}

class _OnDeckPageContent extends HookConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final controller = useTextEditingController();
    final sortDirection = useState(SortDirection.descending);
    final orderBy = useState(UnorderedSortOption.lastRead);

    final series = ref.watch(
      onDeckProvider(
        query: controller.text,
        orderBy: orderBy.value,
        direction: sortDirection.value,
      ),
    );

    useListenable(controller);

    return EntitiesPage(
      title: l.onDeck,
      filterController: controller,
      appBarActions: [
        UnorderedSortMenu(
          sortDirection: sortDirection.value,
          onSortDirectionChanged: (sort) => sortDirection.value = sort,
          orderBy: orderBy.value,
          onOrderByChanged: (order) => orderBy.value = order,
        ),
      ],
      sliver: AsyncSliver(
        asyncValue: series,
        data: (data) => SliverSeriesPageBody(series: data),
      ),
    );
  }
}
