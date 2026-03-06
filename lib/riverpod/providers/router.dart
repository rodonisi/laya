import 'package:flutter/material.dart';
import 'package:fluvita/models/volume_model.dart';
import 'package:fluvita/pages/download_queue/download_queue_page.dart';
import 'package:fluvita/pages/library/volume_detail_page/volume_detail_page.dart';
import 'package:go_router/go_router.dart';
import 'package:fluvita/pages/home/home_page.dart';
import 'package:fluvita/pages/library/menu_page/menu_page.dart';
import 'package:fluvita/pages/library/series_detail_page/series_detail_page.dart';
import 'package:fluvita/pages/library/series_page/series_page.dart';
import 'package:fluvita/pages/library/want_to_read_page/want_to_read_page.dart';
import 'package:fluvita/pages/reader/reader_page.dart';
import 'package:fluvita/pages/settings/settings_page.dart';
import 'package:fluvita/widgets/navigator_container.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

final navigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    navigatorKey: navigatorKey,
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
    TypedStatefulShellBranch<WantToReadBranch>(
      routes: [
        TypedGoRoute<WantToReadRoute>(path: '/want-to-read'),
      ],
    ),
    TypedStatefulShellBranch<LibraryBranch>(
      routes: [
        TypedGoRoute<LibraryRoute>(
          path: '/menu',
          routes: [
            TypedGoRoute<AllSeriesRoute>(
              path: 'all-series',
            ),
            TypedGoRoute<SeriesRoute>(
              path: 'library/:libraryId',
            ),
            TypedGoRoute<SeriesDetailRoute>(
              path: 'series/:seriesId',
            ),
            TypedGoRoute<VolumeDetailRoute>(
              path: 'volume/:volumeId',
            ),
            TypedGoRoute<DownloadQueueRoute>(
              path: 'download-queue',
            ),
            TypedGoRoute<SettingsRoute>(
              path: 'settings',
            ),
          ],
        ),
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

class WantToReadBranch extends StatefulShellBranchData {
  const WantToReadBranch();
}

class LibraryBranch extends StatefulShellBranchData {
  const LibraryBranch();
}

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

class WantToReadRoute extends GoRouteData with $WantToReadRoute {
  const WantToReadRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const WantToReadPage();
}

class LibraryRoute extends GoRouteData with $LibraryRoute {
  const LibraryRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const MenuPage();
}

class AllSeriesRoute extends GoRouteData with $AllSeriesRoute {
  const AllSeriesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AllSeriesPage();
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

class VolumeDetailRoute extends GoRouteData with $VolumeDetailRoute {
  VolumeDetailRoute(this.$extra) : volumeId = $extra.id;

  final int volumeId;
  final VolumeModel $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      VolumeDetailPage(volume: $extra);
}

class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsPage();
}

class DownloadQueueRoute extends GoRouteData with $DownloadQueueRoute {
  const DownloadQueueRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const DownloadQueuePage();
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
