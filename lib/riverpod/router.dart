import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluvita/pages/home/home_page.dart';
import 'package:fluvita/pages/library/libraries_page/libraries_page.dart';
import 'package:fluvita/pages/library/series_detail_page/series_detail_page.dart';
import 'package:fluvita/pages/library/series_page.dart';
import 'package:fluvita/pages/reader/reader_page.dart';
import 'package:fluvita/pages/settings/settings_page.dart';
import 'package:fluvita/widgets/navigator_container.dart';
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
            TypedGoRoute<AllSeriesRoute>(
              path: 'all-series',
            ),
            TypedGoRoute<SeriesRoute>(
              path: ':libraryId/series',
            ),
            TypedGoRoute<SeriesDetailRoute>(path: ':seriesId'),
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

class AllSeriesRoute extends GoRouteData with $AllSeriesRoute {
  const AllSeriesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => AllSeriesPage();
}

class SeriesRoute extends GoRouteData with $SeriesRoute {
  final int libraryId;

  const SeriesRoute({required this.libraryId});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      LibrarySeriesPage(libraryId: libraryId);
}

class SeriesDetailRoute extends GoRouteData with $SeriesDetailRoute {
  const SeriesDetailRoute({required this.libraryId, required this.seriesId});

  final int libraryId;
  final int seriesId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      SeriesDetailPage(seriesId: seriesId);
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
