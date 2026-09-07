import 'package:kover/models/chapter_model.dart';
import 'package:kover/widgets/cards/chapter_card.dart';
import 'package:kover/widgets/lists/list_entries/chapter_list_entry.dart';
import 'package:kover/widgets/sliver_list_page/sliver_page_shell.dart';
import 'package:material_ui/material_ui.dart';

class SliverChaptersPageBody extends StatelessWidget {
  final List<ChapterModel> chapters;
  const new({super.key, required this.chapters});

  @override
  Widget build(BuildContext context) {
    return SliverEntitiesPageBody<ChapterModel>(
      items: chapters,
      gridBuilder: (context, chapter) => ChapterCard(
        key: ValueKey(chapter.id),
        chapterId: chapter.id,
        seriesId: chapter.seriesId,
      ),
      listBuilder: (context, chapter) => ChapterListEntry(
        key: ValueKey(chapter.id),
        chapterId: chapter.id,
        seriesId: chapter.seriesId,
      ),
    );
  }
}
