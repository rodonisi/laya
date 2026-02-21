import 'package:flutter/material.dart';
import 'package:fluvita/riverpod/providers/want_to_read.dart';
import 'package:fluvita/widgets/login_guard.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:fluvita/widgets/series_sliver_grid.dart';
import 'package:fluvita/widgets/sliver_bottom_padding.dart';
import 'package:fluvita/utils/layout_constants.dart';

class WantToReadPage extends ConsumerWidget {
  const WantToReadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.invalidate(wantToReadListProvider);
    final series = ref.watch(wantToReadListProvider);

    return Scaffold(
      extendBody: true,
      body: LoginGuard(
        child: RefreshIndicator(
          onRefresh: () async => await ref.refresh(wantToReadListProvider),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: LayoutConstants.smallEdgeInsets,
                sliver: SliverToBoxAdapter(
                  child: Text(
                    "Want to Read",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
              AsyncSliver(
                asyncValue: series,
                data: (data) => SliverPadding(
                  padding: LayoutConstants.smallEdgeInsets,
                  sliver: SeriesSliverGrid(
                    series: data,
                  ),
                ),
              ),
              const SliverBottomPadding(),
            ],
          ),
        ),
      ),
    );
  }
}
