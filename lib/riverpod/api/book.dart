import 'package:fluvita/models/book_chapter_model.dart';
import 'package:fluvita/models/book_info_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/storage.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hooks_riverpod/experimental/persist.dart';

part 'book.g.dart';

@riverpod
@JsonPersist()
class BookInfo extends _$BookInfo {
  @override
  Future<BookInfoModel> build({required int chapterId}) async {
    persist(ref.watch(storageProvider.future));

    final client = ref.watch(restClientProvider);
    final res = await client.apiBookChapterIdBookInfoGet(chapterId: chapterId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load book info: ${res.error}');
    }

    return BookInfoModel.fromBookInfoDto(res.body!);
  }
}

@riverpod
@JsonPersist()
class BookChapters extends _$BookChapters {
  @override
  Future<List<BookChapterModel>> build({
    required int chapterId,
  }) async {
    persist(ref.watch(storageProvider.future));

    final client = ref.watch(restClientProvider);
    final res = await client.apiBookChapterIdChaptersGet(chapterId: chapterId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load book chapters: ${res.error}');
    }

    return res.body?.map(BookChapterModel.fromChapterItemDto).toList() ?? [];
  }
}

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
