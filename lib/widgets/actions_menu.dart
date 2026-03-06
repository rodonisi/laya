import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ActionsContextMenu extends StatelessWidget {
  final void Function()? onMarkRead;
  final void Function()? onMarkUnread;
  final void Function()? onAddWantToRead;
  final void Function()? onRemoveWantToRead;
  final void Function()? onDownload;
  final void Function()? onRemoveDownload;
  final Widget child;

  const ActionsContextMenu({
    super.key,
    this.onMarkRead,
    this.onMarkUnread,
    this.onAddWantToRead,
    this.onRemoveWantToRead,
    this.onDownload,
    this.onRemoveDownload,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _LocalContextMenuRegion(
      contextMenu: _getContextMenu(
        onMarkRead: onMarkRead,
        onMarkUnread: onMarkUnread,
        onAddWantToRead: onAddWantToRead,
        onRemoveWantToRead: onRemoveWantToRead,
        onDownload: onDownload,
        onRemoveDownload: onRemoveDownload,
      ),
      child: child,
    );
  }
}

class ActionsMenuButton extends StatelessWidget {
  final void Function()? onMarkRead;
  final void Function()? onMarkUnread;
  final void Function()? onDownload;
  final void Function()? onRemoveDownload;
  final Widget child;

  const ActionsMenuButton({
    super.key,
    this.onMarkRead,
    this.onMarkUnread,
    this.onDownload,
    this.onRemoveDownload,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _LocalContextMenuButton(
      contextMenu: _getContextMenu(
        onMarkRead: onMarkRead,
        onMarkUnread: onMarkUnread,
        onDownload: onDownload,
        onRemoveDownload: onRemoveDownload,
      ),
      child: child,
    );
  }
}

class _LocalContextMenuRegion extends StatelessWidget {
  const _LocalContextMenuRegion({
    required this.contextMenu,
    required this.child,
  });

  final ContextMenu contextMenu;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ContextMenuRegion(
      contextMenu: contextMenu,
      child: child,
    );
  }
}

class _LocalContextMenuButton extends StatelessWidget {
  const _LocalContextMenuButton({
    required this.contextMenu,
    required this.child,
  });

  final ContextMenu contextMenu;
  final Widget child;

  void _showMenu(BuildContext context, Offset position) {
    final menu = contextMenu.copyWith(
      position: contextMenu.position ?? position,
    );

    showContextMenu(
      context,
      contextMenu: menu,
      useRootNavigator: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTapUp: (details) => _showMenu(context, details.globalPosition),
      customBorder: const CircleBorder(),
      child: Padding(
        padding: LayoutConstants.smallEdgeInsets,
        child: child,
      ),
    );
  }
}

ContextMenu _getContextMenu({
  void Function()? onMarkRead,
  void Function()? onMarkUnread,
  void Function()? onAddWantToRead,
  void Function()? onRemoveWantToRead,
  void Function()? onDownload,
  void Function()? onRemoveDownload,
}) {
  return ContextMenu(
    entries: [
      ..._wantToReadEntries(
        onAddWantToRead: onAddWantToRead,
        onRemoveWantToRead: onRemoveWantToRead,
      ),
      ..._markReadEntries(
        onMarkRead: onMarkRead,
        onMarkUnread: onMarkUnread,
      ),
      ..._downloadEntries(
        onDownload: onDownload,
        onRemoveDownload: onRemoveDownload,
      ),
    ],
  );
}

List<ContextMenuEntry> _wantToReadEntries({
  void Function()? onAddWantToRead,
  void Function()? onRemoveWantToRead,
}) {
  return [
    if (onAddWantToRead != null)
      MenuItem(
        label: const Text('Add to Want to Read'),
        icon: const Icon(LucideIcons.star),
        onSelected: (_) => onAddWantToRead(),
      ),
    if (onRemoveWantToRead != null)
      MenuItem(
        label: const Text('Remove from Want to Read'),
        icon: const Icon(LucideIcons.starOff),
        onSelected: (_) => onRemoveWantToRead(),
      ),
    if (onAddWantToRead != null || onRemoveWantToRead != null)
      const MenuDivider(),
  ];
}

List<ContextMenuEntry> _markReadEntries({
  void Function()? onMarkRead,
  void Function()? onMarkUnread,
}) {
  return [
    if (onMarkRead != null)
      MenuItem(
        label: const Text('Mark Read'),
        icon: const Icon(LucideIcons.bookCheck),
        onSelected: (_) => onMarkRead(),
      ),
    if (onMarkUnread != null)
      MenuItem(
        label: const Text('Mark Unread'),
        icon: const Icon(LucideIcons.bookX),
        onSelected: (_) => onMarkUnread(),
      ),
    if (onMarkRead != null || onMarkUnread != null) const MenuDivider(),
  ];
}

List<ContextMenuEntry> _downloadEntries({
  void Function()? onDownload,
  void Function()? onRemoveDownload,
}) {
  return [
    if (onDownload != null)
      MenuItem(
        label: const Text('Download'),
        icon: const Icon(LucideIcons.download),
        onSelected: (_) => onDownload(),
      ),
    if (onRemoveDownload != null)
      MenuItem(
        label: const Text('Remove Download'),
        icon: const Icon(LucideIcons.trash2),
        onSelected: (_) => onRemoveDownload(),
      ),
  ];
}
