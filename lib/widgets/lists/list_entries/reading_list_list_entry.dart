import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kover/riverpod/providers/reading_lists.dart';
import 'package:kover/riverpod/providers/router.dart';
import 'package:kover/utils/constants/kover_icons.dart';
import 'package:kover/widgets/cards/cover_image.dart';
import 'package:kover/widgets/lists/cover_list_entry.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:material_ui/material_ui.dart';

class ReadingListListEntry extends ConsumerWidget {
  final int readingListId;

  const new({super.key, required this.readingListId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingList = ref.watch(
      readingListProvider(readingListId: readingListId),
    );
    final progress = ref.watch(
      readingListProgressProvider(readingListId: readingListId),
    );

    return Async(
      asyncValue: readingList,
      data: (data) {
        return CoverListEntry(
          title: data.title,
          progress: progress.value,
          cover: ReadingListCoverImage(readingListId: readingListId),
          trailing: const Icon(KoverIcons.chevronRight),
          onTap: () {
            ReadingListDetailsRoute(readingListId: readingListId).push(context);
          },
        );
      },
      loading: () => const CoverListEntryPlaceholder(),
    );
  }
}
