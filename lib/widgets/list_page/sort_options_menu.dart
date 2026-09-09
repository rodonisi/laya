import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/enums/sort_direction.dart';
import 'package:kover/models/enums/order_by_option.dart';
import 'package:kover/utils/constants/kover_icons.dart';
import 'package:kover/widgets/context_menu/context_menu_button.dart';
import 'package:material_ui/material_ui.dart';

/// Sort menu for unordered entities (series, collections, reading lists).
class UnorderedSortMenu extends StatelessWidget {
  final SortDirection sortDirection;
  final void Function(SortDirection) onSortDirectionChanged;
  final UnorderedSortOption orderBy;
  final void Function(UnorderedSortOption) onOrderByChanged;
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
      icon: _sortIcon(sortDirection),
      menu: _buildSortMenu(
        l: l,
        sortDirection: sortDirection,
        onSortDirectionChanged: onSortDirectionChanged,
        showHideRead: hideRead != null && onHideReadChanged != null,
        hideRead: hideRead,
        onHideReadChanged: onHideReadChanged,
        orderEntries: [
          (l.name, orderBy == .name, () => onOrderByChanged(.name)),
          (l.lastRead, orderBy == .lastRead, () => onOrderByChanged(.lastRead)),
          (l.progress, orderBy == .progress, () => onOrderByChanged(.progress)),
          (
            l.dateAdded,
            orderBy == .dateAdded,
            () => onOrderByChanged(.dateAdded),
          ),
          (
            l.lastModified,
            orderBy == .dateUpdated,
            () => onOrderByChanged(.dateUpdated),
          ),
        ],
      ),
    );
  }
}

/// Sort menu for ordered entities (chapters, volumes) that have a defined
/// [OrderedSortOption.sortOrder].
class OrderedSortMenu extends StatelessWidget {
  final SortDirection sortDirection;
  final void Function(SortDirection) onSortDirectionChanged;
  final OrderedSortOption orderBy;
  final void Function(OrderedSortOption) onOrderByChanged;
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
      icon: _sortIcon(sortDirection),
      menu: _buildSortMenu(
        l: l,
        sortDirection: sortDirection,
        onSortDirectionChanged: onSortDirectionChanged,
        showHideRead: hideRead != null && onHideReadChanged != null,
        hideRead: hideRead,
        onHideReadChanged: onHideReadChanged,
        orderEntries: [
          (
            l.sortOrder,
            orderBy == .sortOrder,
            () => onOrderByChanged(.sortOrder),
          ),
          (l.name, orderBy == .name, () => onOrderByChanged(.name)),
          (l.lastRead, orderBy == .lastRead, () => onOrderByChanged(.lastRead)),
          (l.progress, orderBy == .progress, () => onOrderByChanged(.progress)),
          (
            l.dateAdded,
            orderBy == .dateAdded,
            () => onOrderByChanged(.dateAdded),
          ),
          (
            l.lastModified,
            orderBy == .dateUpdated,
            () => onOrderByChanged(.dateUpdated),
          ),
        ],
      ),
    );
  }
}

ContextMenu _buildSortMenu({
  required AppLocalizations l,
  required SortDirection sortDirection,
  required void Function(SortDirection) onSortDirectionChanged,
  required bool showHideRead,
  bool? hideRead,
  ValueChanged<bool>? onHideReadChanged,
  required List<(String, bool, VoidCallback)> orderEntries,
}) {
  return ContextMenu(
    entries: <ContextMenuEntry>[
      if (showHideRead) ...[
        MenuItem(
          label: Text(l.hideRead),
          icon: _getItemIcon(hideRead!),
          onSelected: (_) {
            onHideReadChanged!(!hideRead);
          },
        ),
      ],
      MenuHeader(text: l.sortBy),
      for (final (label, selected, onSelect) in orderEntries)
        MenuItem(
          label: Text(label),
          icon: _getItemIcon(selected),
          onSelected: (_) => onSelect(),
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

Icon _sortIcon(SortDirection sortDirection) {
  return Icon(
    sortDirection == .ascending ? KoverIcons.ascending : KoverIcons.descending,
  );
}

Icon? _getItemIcon(bool selected) {
  return selected ? const Icon(KoverIcons.check) : null;
}
