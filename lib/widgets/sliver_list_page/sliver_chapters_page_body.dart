import 'package:kover/models/chapter_model.dart';
import 'package:kover/widgets/cards/chapter_card.dart';
import 'package:kover/widgets/lists/list_entries/chapter_list_entry.dart';
import 'package:kover/widgets/sliver_list_page/sliver_page_shell.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class ChaptersListPage extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final AsyncValue<List<ChapterModel>> chapters;
  final Widget? sortMenu;

  const new({
    super.key,
    required this.title,
    required this.controller,
    required this.chapters,
    this.sortMenu,
  });

  @override
  Widget build(BuildContext context) {
    return EntitiesListPage<ChapterModel>(
      title: title,
      filterController: controller,
      items: chapters,
      sortMenu: sortMenu,
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
