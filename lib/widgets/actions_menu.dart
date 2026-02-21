import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ActionsContextMenu extends StatelessWidget {
  final void Function()? onMarkRead;
  final void Function()? onMarkUnread;
  final void Function()? onAddWantToRead;
  final void Function()? onRemoveWantToRead;
  final void Function()? onDownloadChapter;
  final void Function()? onRemoveDownload;
  final void Function()? onDownloadVolume;
  final void Function()? onRemoveVolumeDownload;
  final void Function()? onDownloadSeries;
  final void Function()? onRemoveSeriesDownload;
  final Widget child;

  const ActionsContextMenu({
    super.key,
    this.onMarkRead,
    this.onMarkUnread,
    this.onAddWantToRead,
    this.onRemoveWantToRead,
    this.onDownloadChapter,
    this.onRemoveDownload,
    this.onDownloadVolume,
    this.onRemoveVolumeDownload,
    this.onDownloadSeries,
    this.onRemoveSeriesDownload,
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
        onDownloadChapter: onDownloadChapter,
        onRemoveDownload: onRemoveDownload,
        onDownloadVolume: onDownloadVolume,
        onRemoveVolumeDownload: onRemoveVolumeDownload,
        onDownloadSeries: onDownloadSeries,
        onRemoveSeriesDownload: onRemoveSeriesDownload,
      ),
      child: child,
    );
  }
}

class ActionsMenuButton extends StatelessWidget {
  final void Function()? onMarkRead;
  final void Function()? onMarkUnread;
  final void Function()? onDownloadVolume;
  final void Function()? onRemoveVolumeDownload;
  final void Function()? onDownloadSeries;
  final void Function()? onRemoveSeriesDownload;
  final Widget child;

  const ActionsMenuButton({
    super.key,
    this.onMarkRead,
    this.onMarkUnread,
    this.onDownloadVolume,
    this.onRemoveVolumeDownload,
    this.onDownloadSeries,
    this.onRemoveSeriesDownload,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _LocalContextMenuButton(
      contextMenu: _getContextMenu(
        onMarkRead: onMarkRead,
        onMarkUnread: onMarkUnread,
        onDownloadVolume: onDownloadVolume,
        onRemoveVolumeDownload: onRemoveVolumeDownload,
        onDownloadSeries: onDownloadSeries,
        onRemoveSeriesDownload: onRemoveSeriesDownload,
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
  void Function()? onDownloadChapter,
  void Function()? onRemoveDownload,
  void Function()? onDownloadVolume,
  void Function()? onRemoveVolumeDownload,
  void Function()? onDownloadSeries,
  void Function()? onRemoveSeriesDownload,
}) {
  return ContextMenu(
    entries: [
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
      if (onDownloadChapter != null)
        MenuItem(
          label: const Text('Download Chapter'),
          icon: const Icon(LucideIcons.download),
          onSelected: (_) => onDownloadChapter(),
        ),
      if (onRemoveDownload != null)
        MenuItem(
          label: const Text('Remove Download'),
          icon: const Icon(LucideIcons.trash),
          onSelected: (_) => onRemoveDownload(),
        ),
      if (onDownloadVolume != null)
        MenuItem(
          label: const Text('Download Volume'),
          icon: const Icon(LucideIcons.download),
          onSelected: (_) => onDownloadVolume(),
        ),
      if (onRemoveVolumeDownload != null)
        MenuItem(
          label: const Text('Remove Volume Download'),
          icon: const Icon(LucideIcons.trash),
          onSelected: (_) => onRemoveVolumeDownload(),
        ),
      if (onDownloadSeries != null)
        MenuItem(
          label: const Text('Download Series'),
          icon: const Icon(LucideIcons.download),
          onSelected: (_) => onDownloadSeries(),
        ),
      if (onRemoveSeriesDownload != null)
        MenuItem(
          label: const Text('Remove Series Download'),
          icon: const Icon(LucideIcons.trash),
          onSelected: (_) => onRemoveSeriesDownload(),
        ),
    ],
  );
}
