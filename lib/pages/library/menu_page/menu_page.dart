import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluvita/pages/library/menu_page/sliver_libraries.dart';
import 'package:fluvita/pages/library/menu_page/app_list_tile.dart';
import 'package:fluvita/pages/library/menu_page/sliver_section.dart';
import 'package:fluvita/riverpod/managers/download_manager.dart';
import 'package:fluvita/riverpod/managers/sync_manager.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:fluvita/widgets/login_guard.dart';
import 'package:fluvita/widgets/sliver_bottom_padding.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/providers/router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MenuPage extends ConsumerWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncManagerProvider.notifier).syncLibraries();
    });

    final isDownloading = ref.watch(
      downloadManagerProvider.select(
        (state) => state.value?.downloadQueue.isNotEmpty ?? false,
      ),
    );

    return LoginGuard(
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          extendBody: true,
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: LayoutConstants.mediumEdgeInsets,
                sliver: SliverToBoxAdapter(
                  child: AppListTile(
                    title: 'All Series',
                    icon: const Icon(LucideIcons.list),
                    onTap: () => const AllSeriesRoute().push(context),
                  ),
                ),
              ),
              const SliverSection(title: 'Libraries'),
              const SliverLibraries(),
              const SliverSection(title: 'More'),
              SliverPadding(
                padding: const EdgeInsetsGeometry.symmetric(
                  vertical: LayoutConstants.smallerPadding,
                  horizontal: LayoutConstants.mediumPadding,
                ),
                sliver: SliverToBoxAdapter(
                  child: AppListTile(
                    title: 'Download Queue',
                    icon: isDownloading
                        ? const Icon(LucideIcons.refreshCw)
                              .animate(
                                onPlay: (controller) => controller.repeat(),
                              )
                              .rotate(duration: 1500.ms)
                        : const Icon(LucideIcons.download),
                    onTap: () => const DownloadQueueRoute().push(context),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsetsGeometry.symmetric(
                  vertical: LayoutConstants.smallerPadding,
                  horizontal: LayoutConstants.mediumPadding,
                ),
                sliver: SliverToBoxAdapter(
                  child: AppListTile(
                    title: 'Settings',
                    icon: const Icon(LucideIcons.settings),
                    onTap: () => const SettingsRoute().push(context),
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
