import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/pages/home/home_page.dart';
import 'package:laya/pages/library/chapters_page.dart';
import 'package:laya/pages/library/library_page.dart';
import 'package:laya/pages/library/series_page.dart';
import 'package:laya/pages/reader/reader_page.dart';
import 'package:laya/pages/settings/settings_page.dart';
import 'package:laya/widgets/navigator_container.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: $appRoutes,
  );
}

@TypedStatefulShellRoute<AppShellRoute>(
  branches: [
    TypedStatefulShellBranch<HomeBranch>(
      routes: [
        TypedGoRoute<HomeRoute>(path: '/'),
      ],
    ),
    TypedStatefulShellBranch<LibraryBranch>(
      routes: [
        TypedGoRoute<LibraryRoute>(
          path: '/library',
          routes: [
            TypedGoRoute<SeriesRoute>(
              path: ':libraryId/series',
              routes: [
                TypedGoRoute<ChaptersRoute>(path: ':seriesId/chapters'),
              ],
            ),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<SettingsBranch>(
      routes: [
        TypedGoRoute<SettingsRoute>(path: '/settings'),
      ],
    ),
  ],
)
class AppShellRoute extends StatefulShellRouteData {
  const AppShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return NavigatorContainer(navigationShell: navigationShell);
  }
}

class HomeBranch extends StatefulShellBranchData {
  const HomeBranch();
}

class LibraryBranch extends StatefulShellBranchData {
  const LibraryBranch();
}

class SettingsBranch extends StatefulShellBranchData {
  const SettingsBranch();
}

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

class LibraryRoute extends GoRouteData with $LibraryRoute {
  const LibraryRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const LibraryPage();
}

class SeriesRoute extends GoRouteData with $SeriesRoute {
  final int libraryId;

  const SeriesRoute({required this.libraryId});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      SeriesPage(libraryId: libraryId);
}

class ChaptersRoute extends GoRouteData with $ChaptersRoute {
  const ChaptersRoute({required this.libraryId, required this.seriesId});

  final int libraryId;
  final int seriesId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ChaptersPage(seriesId: seriesId);
}

class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsPage();
}

@TypedGoRoute<ReaderRoute>(path: '/reader/:seriesId')
class ReaderRoute extends GoRouteData with $ReaderRoute {
  final int seriesId;
  final int? chapterId;

  const ReaderRoute({
    required this.seriesId,
    this.chapterId,
  });

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage(
      key: state.pageKey,
      fullscreenDialog: true,
      child: ReaderPage(
        seriesId: seriesId,
        chapterId: chapterId,
      ),
    );
  }
}
