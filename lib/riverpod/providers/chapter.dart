import 'package:fluvita/models/chapter_model.dart';
import 'package:fluvita/models/image_model.dart';
import 'package:fluvita/riverpod/repository/chapters_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'chapter.g.dart';

@riverpod
Stream<ChapterModel> chapter(
  Ref ref, {
  required int chapterId,
}) async* {
  final repo = ref.watch(chaptersRepositoryProvider);
  yield* repo.watchChapter(chapterId: chapterId).distinct();
}

@riverpod
Stream<double> chapterProgress(Ref ref, {required int chapterId}) async* {
  final repo = ref.watch(chaptersRepositoryProvider);
  final chapter = repo.watchChapter(chapterId: chapterId);
  final pagesRead = repo.watchPagesRead(chapterId: chapterId);

  yield* Rx.combineLatest2(
    chapter,
    pagesRead,
    (c, n) => n / c.pages,
  ).distinct();
}

@riverpod
Stream<ImageModel> chapterCover(Ref ref, {required int chapterId}) async* {
  final repo = ref.watch(chaptersRepositoryProvider);
  yield* repo.watchChapterCover(chapterId).distinct();
}
