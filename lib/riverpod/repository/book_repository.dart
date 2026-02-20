import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/models/book_chapter_model.dart';
import 'package:fluvita/models/book_info_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/repository/database.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stream_transform/stream_transform.dart';

part 'book_repository.g.dart';

@riverpod
BookRepository bookRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final restClient = ref.watch(restClientProvider);
  final client = BookRemoteOperations(client: restClient);
  return BookRepository(db, client);
}

class BookRepository {
  final AppDatabase _db;
  final BookRemoteOperations _client;

  BookRepository(this._db, this._client);

  Stream<BookInfoModel> watchBookInfo(int chapterId) {
    refreshBookInfo(chapterId);
    return _db.bookDao
        .watchBookInfo(chapterId)
        .whereNotNull()
        .map(BookInfoModel.fromDatabaseModel);
  }

  Future<void> refreshBookInfo(int chapterId) async {
    try {
      final entry = await _client.getBookInfo(chapterId);
      await _db.bookDao.upsertBookInfo(entry);
    } catch (e) {
      log.e(e);
    }
  }

  Stream<List<BookChapterModel>> watchBookChapters(int chapterId) {
    refreshBookChapters(chapterId);
    return _db.bookDao.watchBookChapters(chapterId).map(_buildTree);
  }

  Future<void> refreshBookChapters(int chapterId) async {
    try {
      final entries = await _client.getBookChapters(chapterId);
      await _db.bookDao.upsertBookChapters(chapterId, entries);
    } catch (e) {
      log.e(e);
    }
  }

  static List<BookChapterModel> _buildTree(
    List<BookChaptersTableData> rows,
  ) {
    List<BookChapterModel> build(int? parentPage) {
      return rows
          .where((r) => r.parentPage == parentPage)
          .map(
            (r) => BookChapterModel(
              title: r.title,
              page: r.page,
              children: build(r.page),
            ),
          )
          .toList();
    }

    return build(null);
  }
}

class BookRemoteOperations {
  final Openapi _client;

  const BookRemoteOperations({required Openapi client}) : _client = client;

  Future<BookInfoCompanion> getBookInfo(int chapterId) async {
    final res = await _client.apiBookChapterIdBookInfoGet(
      chapterId: chapterId,
    );
    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load book info: ${res.error}');
    }
    final dto = res.body!;
    return BookInfoCompanion(
      chapterId: Value(chapterId),
      bookTitle: Value(dto.bookTitle),
      seriesId: Value(dto.seriesId),
      volumeId: Value(dto.volumeId),
      seriesFormat: Value(dto.seriesFormat),
      seriesName: Value(dto.seriesName),
      chapterNumber: Value(dto.chapterNumber),
      volumeNumber: Value(dto.volumeNumber),
      libraryId: Value(dto.libraryId),
      pages: Value(dto.pages),
      isSpecial: Value(dto.isSpecial),
      chapterTitle: Value(dto.chapterTitle),
    );
  }

  Future<Iterable<BookChaptersTableCompanion>> getBookChapters(
    int chapterId,
  ) async {
    final res = await _client.apiBookChapterIdChaptersGet(
      chapterId: chapterId,
    );
    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load book chapters: ${res.error}');
    }
    return _flattenChapters(chapterId, res.body!, null);
  }

  static Iterable<BookChaptersTableCompanion> _flattenChapters(
    int chapterId,
    List<BookChapterItem> items,
    int? parentPage,
  ) sync* {
    for (final item in items) {
      yield BookChaptersTableCompanion(
        chapterId: Value(chapterId),
        title: Value(item.title!),
        page: Value(item.page!),
        parentPage: Value(parentPage),
      );
      if (item.children != null && item.children!.isNotEmpty) {
        yield* _flattenChapters(chapterId, item.children!, item.page!);
      }
    }
  }
}
