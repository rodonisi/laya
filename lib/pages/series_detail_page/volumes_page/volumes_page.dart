import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/enums/order_by_option.dart';
import 'package:kover/models/enums/sort_direction.dart';
import 'package:kover/riverpod/providers/volume.dart';
import 'package:kover/widgets/sliver_list_page/sliver_volumes_page_body.dart';
import 'package:kover/widgets/sliver_list_page/sort_options_menu.dart';
import 'package:material_ui/material_ui.dart';

class VolumesPage extends HookConsumerWidget {
  final int seriesId;
  const VolumesPage({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final hideRead = useState(false);
    final orderBy = useState(OrderedSortOption.sortOrder);
    final sortDirection = useState(SortDirection.ascending);
    final controller = useTextEditingController();

    useListenable(controller);

    final volumes = ref.watch(
      volumesProvider(
        seriesId: seriesId,
        query: controller.text,
        orderBy: orderBy.value,
        direction: sortDirection.value,
        hideRead: hideRead.value,
      ),
    );

    return Scaffold(
      extendBody: true,
      body: VolumesListPage(
        title: l.volumes,
        controller: controller,
        sortMenu: OrderedSortMenu(
          orderBy: orderBy.value,
          onOrderByChanged: (value) => orderBy.value = value,
          sortDirection: sortDirection.value,
          onSortDirectionChanged: (value) => sortDirection.value = value,
          hideRead: hideRead.value,
          onHideReadChanged: (value) => hideRead.value = value,
        ),
        volumes: volumes,
      ),
    );
  }
}
