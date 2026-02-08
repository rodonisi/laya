import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluvita/models/chapter_model.dart';
import 'package:fluvita/riverpod/api/chapter.dart';
import 'package:fluvita/riverpod/api/reader.dart';
import 'package:fluvita/riverpod/router.dart';
import 'package:fluvita/widgets/actions_menu.dart';
import 'package:fluvita/widgets/cover_card.dart';
import 'package:fluvita/widgets/cover_image.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChapterCard extends HookConsumerWidget {
  const ChapterCard({
    super.key,
    required this.chapter,
    required this.seriesId,
  });

  final ChapterModel chapter;
  final int seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chapterProvider(chapterId: chapter.id);

    final state = useState(chapter);

    ref.listen(provider, (previous, next) {
      if (next.hasValue) {
        // keep the title from the argument model as the chapter endpoint may return a different title
        state.value = next.value!.copyWith(title: chapter.title);
      }
    });

    useEffect(() {
      state.value = chapter;
      return null;
    }, [chapter]);

    final markReadProvider = markChapterReadProvider(
      seriesId: seriesId,
      chapterId: state.value.id,
    );

    return ActionsContextMenu(
      onMarkRead: () async {
        await ref.read(markReadProvider.notifier).markRead();
        ref.invalidate(provider);
      },
      onMarkUnread: () async {
        await ref.read(markReadProvider.notifier).markUnread();
        ref.invalidate(provider);
      },
      child: CoverCard(
        title: state.value.title,
        coverImage: ChapterCoverImage(chapterId: state.value.id),
        progress: state.value.progress,
        onTap: () {
          ReaderRoute(
            seriesId: seriesId,
            chapterId: state.value.id,
          ).push(context);
        },
      ),
    );
  }
}
