import 'package:flutter/material.dart';
import 'package:fluvita/pages/library/libraries_page/app_list_tile.dart';
import 'package:fluvita/pages/library/libraries_page/sliver_libraries.dart';
import 'package:fluvita/pages/library/libraries_page/sliver_section.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:fluvita/widgets/login_guard.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/router.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoginGuard(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: LayoutConstants.mediumEdgeInsets,
            sliver: SliverToBoxAdapter(
              child: AppListTile(
                title: 'All Series',
                icon: FaIcon(FontAwesomeIcons.solidRectangleList),
                onTap: () => AllSeriesRoute().push(context),
              ),
            ),
          ),
          SliverSection(title: 'Libraries'),
          SliverLibraries(),
        ],
      ),
    );
  }
}
