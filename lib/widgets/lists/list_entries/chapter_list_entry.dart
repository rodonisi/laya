import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kover/riverpod/providers/chapter.dart';
import 'package:kover/riverpod/providers/router.dart';
import 'package:kover/utils/constants/kover_icons.dart';
import 'package:kover/widgets/cards/cover_image.dart';
import 'package:kover/widgets/lists/cover_list_entry.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:material_ui/material_ui.dart';

class ChapterListEntry extends ConsumerWidget {
  final int chapterId;
  final int seriesId;

  const new({super.key, required this.chapterId, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapter = ref.watch(chapterProvider(chapterId: chapterId));
    final progress = ref.watch(chapterProgressProvider(chapterId: chapterId));

    return Async(
      asyncValue: chapter,
      data: (data) {
        return CoverListEntry(
          title: data.title,
          progress: progress.value,
          cover: ChapterCoverImage(chapterId: chapterId),
          trailing: const Icon(KoverIcons.chevronRight),
          onTap: () {
            ChapterDetailRoute(
              seriesId: seriesId,
              chapterId: chapterId,
            ).go(context);
          },
        );
      },
      loading: () => const CoverListEntryPlaceholder(),
    );
  }
}
