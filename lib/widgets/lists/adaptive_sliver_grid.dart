import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kover/utils/layout_constants.dart';

class AdaptiveSliverGrid extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = switch (constraints.crossAxisExtent) {
          final width when width >= LayoutBreakpoints.large => 10,
          final width when width >= LayoutBreakpoints.expanded => 8,
          final width when width >= LayoutBreakpoints.medium => 6,
          final width when width >= LayoutBreakpoints.compact => 4,
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
