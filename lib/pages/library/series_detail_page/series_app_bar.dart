import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluvita/pages/library/series_detail_page/series_info.dart';
import 'package:fluvita/riverpod/api/series.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SeriesAppBar extends HookConsumerWidget {
  static const height = 500.0;
  static const expandedSummaryHeight = 800.0;

  final int seriesId;
  final PreferredSizeWidget? bottom;

  const SeriesAppBar({
    super.key,
    required this.seriesId,
    this.bottom,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(seriesProvider(seriesId: seriesId));
    final isCollapsed = useState(false);
    final expandedHeight = useState(height);

    return AsyncSliver(
      asyncValue: series,
      data: (data) {
        return SliverAppBar(
          title: isCollapsed.value
              ? Text(
                  data.name,
                ).animate(target: isCollapsed.value ? 1 : 0).fade()
              : null,
          pinned: true,
          expandedHeight: expandedHeight.value,
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                isCollapsed.value =
                    constraints.biggest.height <=
                    kToolbarHeight + (bottom?.preferredSize.height ?? .0);
              });

              final value =
                  (constraints.biggest.height - kToolbarHeight) /
                  (expandedHeight.value - kToolbarHeight);

              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: FlexibleSpaceBar(
                  background: SeriesInfo(seriesId: data.id),
                ),
              );
            },
          ),
          bottom: bottom,
        );
      },
    );
  }
}
