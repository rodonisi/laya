import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/utils/layout_constants.dart';

class NavigatorContainer extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavigatorContainer({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(child: navigationShell),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: LayoutConstants.mediumPadding,
          right: LayoutConstants.mediumPadding,
          bottom: LayoutConstants.mediumPadding,
        ),
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          removeTop: true,
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.all(Radius.circular(24.0)),
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) => navigationShell.goBranch(
                index,
              ),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.library_books),
                  label: 'Libraries',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings),
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
