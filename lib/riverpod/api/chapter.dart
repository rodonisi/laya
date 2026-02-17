import 'package:fluvita/models/chapter_model.dart';
import 'package:fluvita/models/image_model.dart';
import 'package:fluvita/riverpod/repository/chapters_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chapter.g.dart';

@riverpod
Stream<ChapterModel> chapter(
  Ref ref, {
  required int chapterId,
}) async* {
  final repo = ref.watch(chaptersRepositoryProvider);
  yield* repo.watchChapter(chapterId: chapterId);
}

@riverpod
Stream<ImageModel> chapterCover(Ref ref, {required int chapterId}) async* {
  final repo = ref.watch(chaptersRepositoryProvider);
  yield* repo.watchChapterCover(chapterId);
}
