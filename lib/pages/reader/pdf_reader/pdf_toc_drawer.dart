import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kover/riverpod/providers/reader/reader_navigation.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfTocDrawer extends ConsumerWidget {
  final PdfViewerController controller;
  final List<PdfOutlineNode> toc;
  final int seriesId;
  final int chapterId;
  const PdfTocDrawer({
    super.key,
    required this.controller,
    required this.toc,
    required this.seriesId,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = _getOutlineList(toc, 0).toList();
    final nav = ref.watch(
      readerNavigationProvider(seriesId: seriesId, chapterId: chapterId),
    );

    final currentDestIndex = list.lastIndexWhere(
      (item) => (item.node.dest?.pageNumber ?? 0) <= nav.currentPage,
    );

    final key = GlobalKey();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          alignment: 0.2,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    return Drawer(
      child: SingleChildScrollView(
        child: Padding(
          padding: LayoutConstants.mediumEdgeInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: LayoutConstants.smallPadding,
            crossAxisAlignment: .start,
            children: [
              Text(
                'Table of Contents',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              ...list.indexed.map(
                (entry) {
                  final (index, item) = entry;
                  final selected = index == currentDestIndex;
                  return ListTile(
                    key: index == currentDestIndex ? key : null,
                    onTap: () => controller.goToDest(item.node.dest),
                    contentPadding: 
                         EdgeInsetsGeometry.only(
                            left: item.level * LayoutConstants.largePadding,
                            right: LayoutConstants.mediumPadding,
                          ),
                    selected: selected,
                    title: Text(
                      item.node.title,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Recursively create outline indent structure
  Iterable<({PdfOutlineNode node, int level})> _getOutlineList(
    List<PdfOutlineNode>? outline,
    int level,
  ) sync* {
    if (outline == null) return;
    for (var node in outline) {
      yield (node: node, level: level);
      yield* _getOutlineList(node.children, level + 1);
    }
  }
}
