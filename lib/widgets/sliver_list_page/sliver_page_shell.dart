import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kover/database/app_database.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/enums/sort_direction.dart';
import 'package:kover/models/series_model.dart';
import 'package:kover/riverpod/providers/router.dart';
import 'package:kover/riverpod/providers/series.dart';
import 'package:kover/riverpod/repository/series_repository.dart';
import 'package:kover/utils/constants/kover_icons.dart';
import 'package:kover/widgets/cards/cover_image.dart';
import 'package:kover/widgets/cards/series_card.dart';
import 'package:kover/widgets/context_menu/context_menu_button.dart';
import 'package:kover/widgets/lists/adaptive_sliver_grid.dart';
import 'package:kover/widgets/lists/cover_list_entry.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:kover/widgets/util/sliver_adaptive_padding.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/details/filter_input_field.dart';
import 'package:kover/widgets/util/sliver_bottom_padding.dart';
import 'package:pdfrx/pdfrx.dart';

// class SliverPageShell extends StatelessWidget {
//   final String title;
//   final List<Widget> appBarActions;
//   final TextEditingController filterController;
//   final List<Widget> slivers;
//
//   const new({
//     super.key,
//     required this.title,
//     required this.filterController,
//     required this.slivers,
//     this.appBarActions = const [],
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       keyboardDismissBehavior: .onDrag,
//       slivers: [
//         SliverAppBar.large(
//           title: Text(title),
//           actionsPadding: const EdgeInsets.symmetric(
//             horizontal: LayoutConstants.smallPadding,
//           ),
//           actions: appBarActions,
//         ),
//         SliverSafeArea(
//           top: false,
//           bottom: false,
//           sliver: SliverMainAxisGroup(
//             slivers: [
//               SliverPadding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: LayoutConstants.mediumPadding,
//                 ),
//                 sliver: SliverToBoxAdapter(
//                   child: FilterInputField(controller: filterController),
//                 ),
//               ),
//               ...slivers,
//             ],
//           ),
//         ),
//         const SliverBottomPadding(),
//       ],
//     );
//   }
// }

class EntitiesPage extends HookWidget {
  final String title;
  final List<Widget> appBarActions;
  final TextEditingController filterController;
  final Widget sliver;

  const new({
    super.key,
    required this.title,
    required this.filterController,
    required this.sliver,
    this.appBarActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isGrid = useState(true);

    return CustomScrollView(
      keyboardDismissBehavior: .onDrag,
      slivers: [
        SliverAppBar.large(
          title: Text(title),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: LayoutConstants.smallPadding,
          ),
          actions: [
            IconButton(
              icon: Icon(isGrid.value ? KoverIcons.list : KoverIcons.grid),
              onPressed: () {
                isGrid.value = !isGrid.value;
              },
            ),
            ...appBarActions,
          ],
        ),
        SliverSafeArea(
          top: false,
          bottom: false,
          sliver: SliverMainAxisGroup(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutConstants.mediumPadding,
                ),
                sliver: SliverToBoxAdapter(
                  child: FilterInputField(controller: filterController),
                ),
              ),
              EntitiesPageScope(isGrid: isGrid.value, child: sliver),
            ],
          ),
        ),
        const SliverBottomPadding(),
      ],
    );
  }
}

class SliverSeriesPageBody extends StatelessWidget {
  final List<SeriesModel> series;
  const new({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    return SliverEntitiesPageBody<SeriesModel>(
      items: series,
      gridBuilder: (context, series) =>
          SeriesCard(key: ValueKey(series.id), seriesId: series.id),
      listBuilder: (context, series) =>
          SeriesListEntry(key: ValueKey(series.id), seriesId: series.id),
    );
  }
}

class SeriesSortOptionsMenu extends StatelessWidget {
  final SortDirection sortDirection;
  final void Function(SortDirection) onSortDirectionChanged;
  final SeriesOrderByColumn orderBy;
  final void Function(SeriesOrderByColumn) onOrderByChanged;
  final bool? hideRead;
  final void Function(bool)? onHideReadChanged;
  const new({
    super.key,
    required this.sortDirection,
    required this.onSortDirectionChanged,
    required this.orderBy,
    required this.onOrderByChanged,
    this.hideRead,
    this.onHideReadChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ContextMenuButton(
      icon: Icon(
        sortDirection == .ascending
            ? LucideIcons.arrowDownNarrowWide
            : LucideIcons.arrowDownWideNarrow,
      ),
      menu: _menu(l),
    );
  }

  ContextMenu _menu(AppLocalizations l) {
    return ContextMenu(
      entries: <ContextMenuEntry>[
        if (hideRead != null && onHideReadChanged != null) ...[
          MenuItem(
            label: Text(l.hideRead),
            icon: _getItemIcon(hideRead!),
            onSelected: (_) {
              onHideReadChanged!(!hideRead!);
            },
          ),
        ],
        MenuHeader(text: l.sortBy),
        MenuItem(
          label: Text(l.name),
          icon: _getItemIcon(orderBy == .name),
          onSelected: (_) {
            onOrderByChanged(.name);
          },
        ),
        MenuItem(
          label: Text(l.progress),
          icon: _getItemIcon(orderBy == .progress),
          onSelected: (_) {
            onOrderByChanged(.progress);
          },
        ),
        MenuItem(
          label: Text(l.dateAdded),
          icon: _getItemIcon(orderBy == .dateAdded),
          onSelected: (_) {
            onOrderByChanged(.dateAdded);
          },
        ),
        MenuItem(
          label: Text(l.lastModified),
          icon: _getItemIcon(orderBy == .dateUpdated),
          onSelected: (_) {
            onOrderByChanged(.dateUpdated);
          },
        ),
        MenuHeader(text: l.sortDirection),
        MenuItem(
          label: Text(l.ascending),
          icon: _getItemIcon(sortDirection == .ascending),
          onSelected: (_) {
            onSortDirectionChanged(.ascending);
          },
        ),
        MenuItem(
          label: Text(l.descending),
          icon: _getItemIcon(sortDirection == .descending),
          onSelected: (_) {
            onSortDirectionChanged(.descending);
          },
        ),
      ],
    );
  }

  Icon? _getItemIcon(bool selected) {
    return selected ? const Icon(LucideIcons.check) : null;
  }
}

class SliverEntitiesPageBody<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item) gridBuilder;
  final Widget Function(BuildContext context, T item) listBuilder;
  const new({
    super.key,
    required this.items,
    required this.gridBuilder,
    required this.listBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final isGrid = EntitiesPageScope.of(context).isGrid;

    if (isGrid) {
      return SliverPadding(
        padding: LayoutConstants.smallEdgeInsets,
        sliver: AdaptiveSliverGrid(
          builder: (context, index) => gridBuilder(context, items[index]),
          itemCount: items.length,
        ),
      );
    }

    return SliverAdaptivePadding(
      padding: LayoutConstants.smallEdgeInsets,
      sliver: SliverList.separated(
        itemBuilder: (context, index) => listBuilder(context, items[index]),
        separatorBuilder: (context, index) => const SizedBox(
          height: LayoutConstants.listSpacing,
        ),
        itemCount: items.length,
      ),
    );
  }
}

class EntitiesPageScope extends InheritedWidget {
  final bool isGrid;

  const new({
    super.key,
    required this.isGrid,
    required super.child,
  });

  static EntitiesPageScope of(BuildContext context) {
    final EntitiesPageScope? result = context
        .dependOnInheritedWidgetOfExactType<EntitiesPageScope>();
    assert(result != null, 'No EntitiesPageScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(EntitiesPageScope oldWidget) {
    return isGrid != oldWidget.isGrid;
  }
}

class SeriesListEntry extends ConsumerWidget {
  final int seriesId;

  const new({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(seriesProvider(seriesId: seriesId));
    final progress = ref.watch(seriesProgressProvider(seriesId: seriesId));

    return Async(
      asyncValue: series,
      data: (data) {
        return CoverListEntry(
          title: data.name,
          progress: progress.value,
          cover: SeriesCoverImage(seriesId: seriesId),
          trailing: const Icon(KoverIcons.chevronRight),
          onTap: () {
            SeriesDetailRoute(seriesId: seriesId).go(context);
          },
        );
      },
      loading: () => CoverListEntryPlaceholder(),
    );
  }
}
