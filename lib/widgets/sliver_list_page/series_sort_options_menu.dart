import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/enums/sort_direction.dart';
import 'package:kover/models/enums/order_by_option.dart';
import 'package:kover/widgets/context_menu/context_menu_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

class SeriesSortOptionsMenu extends StatelessWidget {
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
          label: Text(l.lastRead),
          icon: _getItemIcon(orderBy == .lastRead),
          onSelected: (_) {
            onOrderByChanged(.lastRead);
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

class OrderedEntityOrderMenu extends StatelessWidget {
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
          label: Text(l.sortOrder),
          icon: _getItemIcon(orderBy == .sortOrder),
          onSelected: (_) {
            onOrderByChanged(.sortOrder);
          },
        ),
        MenuItem(
          label: Text(l.name),
          icon: _getItemIcon(orderBy == .name),
          onSelected: (_) {
            onOrderByChanged(.name);
          },
        ),
        MenuItem(
          label: Text(l.lastRead),
          icon: _getItemIcon(orderBy == .lastRead),
          onSelected: (_) {
            onOrderByChanged(.lastRead);
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
