import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/enums/sort_direction.dart';
import 'package:kover/widgets/context_menu/context_menu_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

class SortDirectionMenu extends StatelessWidget {
  final SortDirection sortDirection;
  final void Function(SortDirection) onSortDirectionChanged;

  const new({
    super.key,
    required this.sortDirection,
    required this.onSortDirectionChanged,
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
      menu: ContextMenu(
        entries: [
          MenuHeader(text: l.sortDirection),
          MenuItem(
            label: Text(l.ascending),
            icon: _getItemIcon(sortDirection == .ascending),
            onSelected: (_) => onSortDirectionChanged(.ascending),
          ),
          MenuItem(
            label: Text(l.descending),
            icon: _getItemIcon(sortDirection == .descending),
            onSelected: (_) => onSortDirectionChanged(.descending),
          ),
        ],
      ),
    );
  }

  Icon? _getItemIcon(bool selected) {
    return selected ? const Icon(LucideIcons.check) : null;
  }
}
