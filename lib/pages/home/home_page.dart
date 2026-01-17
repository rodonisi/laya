import 'package:flutter/material.dart';
import 'package:fluvita/widgets/login_guard.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/pages/home/collapsible_section.dart';
import 'package:fluvita/riverpod/api/series.dart';
import 'package:fluvita/widgets/sliver_bottom_padding.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: true,
      body: LoginGuard(child: HomePageContent()),
    );
  }
}

class HomePageContent extends ConsumerWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _invalidateProviders(ref);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async {
          await _invalidateProviders(ref);
        },
        child: CustomScrollView(
          slivers: [
            OnDeck(),
            RecentlyUpdated(),
            RecentlyAdded(),
            SliverBottomPadding(),
          ],
        ),
      ),
    );
  }

  Future<void> _invalidateProviders(WidgetRef ref) async {
    final _ = await ref.refresh(onDeckProvider.future);
    final _ = await ref.refresh(recentlyUpdatedProvider.future);
    final _ = await ref.refresh(recentlyAddedProvider.future);
  }
}

class OnDeck extends ConsumerWidget {
  const OnDeck({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onDeck = ref.watch(onDeckProvider);

    return CollapsibleSection(title: 'On Deck', series: onDeck);
  }
}

class RecentlyUpdated extends ConsumerWidget {
  const RecentlyUpdated({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(recentlyUpdatedProvider);

    return CollapsibleSection(title: 'Recently Updated', series: series);
  }
}

class RecentlyAdded extends ConsumerWidget {
  const RecentlyAdded({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(recentlyAddedProvider);

    return CollapsibleSection(title: 'Recently Added', series: series);
  }
}
