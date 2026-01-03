import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:fluvita/utils/layout_constants.dart';

class NavigatorContainer extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavigatorContainer({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
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
                initialLocation: true,
              ),
              destinations: const [
                NavigationDestination(
                  icon: Icon(FontAwesomeIcons.solidHouse),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(FontAwesomeIcons.book),
                  label: 'Libraries',
                ),
                NavigationDestination(
                  icon: Icon(FontAwesomeIcons.gear),
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
