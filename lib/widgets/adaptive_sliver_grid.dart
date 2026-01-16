import 'package:flutter/material.dart';
import 'package:fluvita/utils/layout_constants.dart';

class AdaptiveSliverGrid extends StatelessWidget {
  final int itemCount;
  final int? rowCount;
  final NullableIndexedWidgetBuilder builder;

  const AdaptiveSliverGrid({
    super.key,
    required this.builder,
    required this.itemCount,
    this.rowCount,
  });

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = switch (constraints.crossAxisExtent) {
          final width when width >= Breakpoints.large => 10,
          final width when width >= Breakpoints.expanded => 8,
          final width when width >= Breakpoints.medium => 6,
          final width when width >= Breakpoints.compact => 4,
          _ => 3,
        };

        final items = rowCount != null
            ? (rowCount! * crossAxisCount).clamp(0, itemCount)
            : itemCount;

        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: LayoutConstants.chapterCardAspectRatio,
          ),
          delegate: SliverChildBuilderDelegate(
            builder,
            childCount: items,
          ),
        );
      },
    );
  }
}
