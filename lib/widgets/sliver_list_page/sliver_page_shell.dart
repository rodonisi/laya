import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kover/utils/constants/kover_icons.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/details/filter_input_field.dart';
import 'package:kover/widgets/lists/adaptive_sliver_grid.dart';
import 'package:kover/widgets/util/sliver_adaptive_padding.dart';
import 'package:kover/widgets/util/sliver_bottom_padding.dart';
import 'package:material_ui/material_ui.dart';

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
