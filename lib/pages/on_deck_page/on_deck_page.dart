import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/enums/sort_direction.dart';
import 'package:kover/models/series_model.dart';
import 'package:kover/riverpod/repository/series_repository.dart';
import 'package:kover/riverpod/providers/series.dart';
import 'package:kover/widgets/sliver_list_page/sliver_page_shell.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:kover/widgets/util/login_guard.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'on_deck_page.g.dart';

@riverpod
Future<List<SeriesModel>> _filteredOnDeck(
  Ref ref, {
  required String query,
  SeriesOrderByColumn orderBy = .progress,
  SortDirection direction = .ascending,
}) async {
  final repo = ref.watch(seriesRepositoryProvider);
  final onDeck = await ref.watch(onDeckProvider.future);

  if (query.isEmpty) return onDeck;

  return await repo.filterOnDeck(
    query,
    orderBy: orderBy,
    direction: direction,
  );
}

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
    final sortDirection = useState(SortDirection.ascending);
    final orderBy = useState(SeriesOrderByColumn.progress);

    final series = ref.watch(
      _filteredOnDeckProvider(query: controller.text),
    );
    useListenable(controller);
    return EntitiesPage(
      title: l.onDeck,
      filterController: controller,
      appBarActions: [
        SeriesSortOptionsMenu(
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
