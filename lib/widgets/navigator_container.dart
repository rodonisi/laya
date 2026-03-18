import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/riverpod/managers/sync_manager.dart';
import 'package:kover/riverpod/providers/theme.dart' hide Theme;
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/async_value.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

String _phaseLabel(SyncPhase phase) => switch (phase) {
  .allSeries => 'Syncing series...',
  .seriesDetails => 'Syncing series details...',
  .metadata => 'Syncing metadata...',
  .libraries => 'Syncing libraries...',
  .recentlyAdded => 'Syncing recently added...',
  .recentlyUpdated => 'Syncing recently updated...',
  .progress => 'Syncing progress...',
  .covers => 'Syncing covers...',
  _ => 'Unknown state',
};

class NavigatorContainer extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const NavigatorContainer({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(syncManagerProvider, (prev, next) {
      next.when(
        idle: () {
          ScaffoldMessenger.of(context).clearSnackBars();
        },
        syncing: (phase) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: .floating,
              persist: true,
              content: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(_phaseLabel(phase)),
                  SizedBox.square(
                    dimension: LayoutConstants.mediumIcon,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ],
              ),
              // Keep visible until replaced by the next state transition.
              // duration: const Duration(days: 1),
            ),
          );
        },
        error: (phase, error) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: .floating,
              content: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text('Failed to sync ${_phaseLabel(phase)}'),
                  Icon(
                    LucideIcons.circleX,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
              // Keep visible until replaced by the next state transition.
              // duration: const Duration(days: 1),
            ),
          );
        },
      );
    });

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: LayoutConstants.mediumPadding,
          right: LayoutConstants.mediumPadding,
          bottom: LayoutConstants.mediumPadding,
        ),
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          removeTop: true,
          child: Async(
            asyncValue: ref.watch(themeProvider),
            data: (theme) => Card(
              clipBehavior: .hardEdge,
              shape: RoundedRectangleBorder(
                side: theme.outlined
                    ? BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 2.0,
                      )
                    : BorderSide.none,
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: (index) {
                  navigationShell.goBranch(
                    index,
                    initialLocation: true,
                  );
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(LucideIcons.house),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(LucideIcons.star),
                    label: 'Want to Read',
                  ),
                  NavigationDestination(
                    icon: Icon(LucideIcons.library),
                    label: 'Menu',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
