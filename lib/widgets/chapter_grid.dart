import 'package:flutter/material.dart';
import 'package:fluvita/models/chapter_model.dart';
import 'package:fluvita/widgets/adaptive_sliver_grid.dart';
import 'package:fluvita/widgets/chapter_card.dart';

class ChapterGrid extends StatelessWidget {
  final int seriesId;
  final List<ChapterModel> chapters;

  const ChapterGrid({
    super.key,
    required this.seriesId,
    required this.chapters,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveSliverGrid(
      itemCount: chapters.length,
      builder: (context, index) {
        final chapter = chapters[index];
        return ChapterCard(chapterId: chapter.id, seriesId: seriesId);
      },
    );
  }
}
