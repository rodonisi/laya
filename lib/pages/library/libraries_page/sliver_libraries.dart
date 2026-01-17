import 'package:flutter/material.dart';
import 'package:fluvita/models/library_model.dart';
import 'package:fluvita/pages/library/libraries_page/app_list_tile.dart';
import 'package:fluvita/riverpod/api/library.dart';
import 'package:fluvita/riverpod/router.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SliverLibraries extends ConsumerWidget {
  const SliverLibraries({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libs = ref.watch(librariesProvider);

    return AsyncSliver(
      asyncValue: libs,
      data: (data) {
        return SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: LayoutConstants.mediumPadding,
            vertical: LayoutConstants.smallPadding,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == data.length - 1
                        ? 0
                        : LayoutConstants.smallPadding,
                  ),
                  child: LibraryListTile(lib: data[index]),
                );
              },
              childCount: data.length,
            ),
          ),
        );
      },
    );
  }
}

class LibraryListTile extends StatelessWidget {
  const LibraryListTile({
    super.key,
    required this.lib,
  });

  final LibraryModel lib;

  @override
  Widget build(BuildContext context) {
    final leading = FaIcon(switch (lib.type) {
      .book || .lightNovel => FontAwesomeIcons.book,
      .manga || .comic => FontAwesomeIcons.bookOpen,
      _ => FontAwesomeIcons.question,
    });

    return AppListTile(
      title: lib.name,
      icon: leading,
      onTap: () => SeriesRoute(libraryId: lib.id).push(context),
    );
  }
}
