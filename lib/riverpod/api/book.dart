import 'package:fluvita/models/book_chapter_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/repository/book_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'book.g.dart';

@riverpod
Stream<List<BookChapterModel>> bookChapters(
  Ref ref, {
  required int chapterId,
}) async* {
  final repo = ref.watch(bookRepositoryProvider);
  yield* repo.watchBookChapters(chapterId);
}

/// Raw HTML page content — ephemeral, not cached in the DB.
@riverpod
Future<String> bookPage(Ref ref, {required int chapterId, int? page}) async {
  final client = ref.watch(restClientProvider);
  final res = await client.apiBookChapterIdBookPageGet(
    chapterId: chapterId,
    page: page,
  );

  if (!res.isSuccessful || res.body == null) {
    throw Exception('Failed to load book page: ${res.error}');
  }

  return res.body!;
}
