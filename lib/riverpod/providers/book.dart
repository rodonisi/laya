import 'package:fluvita/models/book_chapter_model.dart';
import 'package:fluvita/models/image_model.dart';
import 'package:fluvita/models/page_content.dart';
import 'package:fluvita/riverpod/repository/book_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'book.g.dart';

@riverpod
Stream<List<BookChapterModel>> bookChapters(
  Ref ref, {
  required int chapterId,
}) async* {
  final repo = ref.watch(bookRepositoryProvider);
  yield* repo.watchBookChapters(chapterId).distinct();
}

@riverpod
Future<PageContent> epubPage(
  Ref ref, {
  required int chapterId,
  required int page,
}) async {
  final repo = ref.watch(bookRepositoryProvider);
  return repo.getEpubPage(chapterId: chapterId, page: page);
}

@riverpod
Future<ImageModel> imagePage(
  Ref ref, {
  required int chapterId,
  required int page,
}) async {
  final repo = ref.watch(bookRepositoryProvider);
  return repo.getImagePage(chapterId: chapterId, page: page);
}
