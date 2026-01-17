import 'package:flutter/material.dart';
import 'package:fluvita/models/library_model.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/api/library.dart';
import 'package:fluvita/riverpod/router.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
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
    );
  }
}

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

class SliverSection extends StatelessWidget {
  final String title;

  const SliverSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: LayoutConstants.mediumEdgeInsets,
      sliver: SliverToBoxAdapter(
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    this.icon,
    this.onTap,
  });

  final String title;
  final Widget? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: icon != null
            ? CircleAvatar(
                child: icon,
              )
            : null,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
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
