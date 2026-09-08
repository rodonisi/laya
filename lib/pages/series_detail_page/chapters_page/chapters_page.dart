import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/chapter_model.dart';
import 'package:kover/models/enums/order_by_option.dart';
import 'package:kover/models/enums/sort_direction.dart';
import 'package:kover/riverpod/providers/chapter.dart';
import 'package:kover/widgets/sliver_list_page/sort_options_menu.dart';
import 'package:kover/widgets/sliver_list_page/sliver_chapters_page_body.dart';
import 'package:kover/widgets/sliver_list_page/sliver_page_shell.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:material_ui/material_ui.dart';

class ChaptersPage extends HookConsumerWidget {
  final int seriesId;
  final int? volumeId;
  const ChaptersPage({super.key, required this.seriesId, this.volumeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final hideRead = useState(false);
    final sortDirection = useState(SortDirection.ascending);
    final orderBy = useState(OrderedSortOption.sortOrder);
    final controller = useTextEditingController();

    useListenable(controller);

    final chapters = ref.watch(
      filteredChaptersProvider(
        seriesId: seriesId,
        volumeId: volumeId,
        hideRead: hideRead.value,
        query: controller.text,
        direction: sortDirection.value,
      ),
    );

    return _ChaptersPage(
      title: l.chapters,
      chapters: chapters,
      controller: controller,
      action: OrderedSortMenu(
        sortDirection: sortDirection.value,
        onSortDirectionChanged: (newDirection) =>
            sortDirection.value = newDirection,
        orderBy: orderBy.value,
        onOrderByChanged: (value) => orderBy.value = value,
        hideRead: hideRead.value,
        onHideReadChanged: (newHideRead) => hideRead.value = newHideRead,
      ),
    );
  }
}

class StorylinePage extends HookConsumerWidget {
  final int seriesId;
  const StorylinePage({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final orderBy = useState(OrderedSortOption.sortOrder);
    final sortDirection = useState(SortDirection.ascending);
    final hideRead = useState(false);
    final controller = useTextEditingController();

    useListenable(controller);

    final chapters = ref.watch(
      filteredChaptersProvider(
        seriesId: seriesId,
        kind: .storyline,
        query: controller.text,
        orderBy: orderBy.value,
        direction: sortDirection.value,
        hideRead: hideRead.value,
      ),
    );

    return _ChaptersPage(
      title: l.storyline,
      chapters: chapters,
      controller: controller,
      action: OrderedSortMenu(
        sortDirection: sortDirection.value,
        onSortDirectionChanged: (value) => sortDirection.value = value,
        orderBy: orderBy.value,
        onOrderByChanged: (value) => orderBy.value = value,
        hideRead: hideRead.value,
        onHideReadChanged: (value) => hideRead.value = value,
      ),
    );
  }
}

class SpecialsPage extends HookConsumerWidget {
  final int seriesId;
  const SpecialsPage({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final orderBy = useState(OrderedSortOption.sortOrder);
    final sortDirection = useState(SortDirection.ascending);
    final hideRead = useState(false);
    final controller = useTextEditingController();

    useListenable(controller);

    final chapters = ref.watch(
      filteredChaptersProvider(
        seriesId: seriesId,
        kind: .specials,
        query: controller.text,
        orderBy: orderBy.value,
        direction: sortDirection.value,
        hideRead: hideRead.value,
      ),
    );

    return _ChaptersPage(
      title: l.specials,
      chapters: chapters,
      controller: controller,
      action: OrderedSortMenu(
        sortDirection: sortDirection.value,
        onSortDirectionChanged: (newDirection) =>
            sortDirection.value = newDirection,
        orderBy: orderBy.value,
        onOrderByChanged: (newOrderBy) => orderBy.value = newOrderBy,
        hideRead: hideRead.value,
        onHideReadChanged: (newHideRead) => hideRead.value = newHideRead,
      ),
    );
  }
}

class _ChaptersPage extends HookConsumerWidget {
  final String title;
  final AsyncValue<List<ChapterModel>> chapters;
  final TextEditingController controller;
  final Widget? action;
  const _ChaptersPage({
    required this.title,
    required this.chapters,
    required this.controller,
    this.action,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: true,
      body: EntitiesPage(
        title: title,
        filterController: controller,
        appBarActions: [
          ?action,
        ],
        sliver: AsyncSliver(
          asyncValue: chapters,
          data: (data) => SliverChaptersPageBody(chapters: data),
        ),
      ),
    );
  }
}
