import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NavigatorContainer extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const NavigatorContainer({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          child: ClipRRect(
            borderRadius: const BorderRadiusGeometry.all(Radius.circular(24.0)),
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
                  label: 'Libraries',
                ),
                NavigationDestination(
                  icon: Icon(LucideIcons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
