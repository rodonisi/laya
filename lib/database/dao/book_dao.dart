import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/book_info.dart';

part 'book_dao.g.dart';

@DriftAccessor(tables: [BookInfo, BookChaptersTable])
class BookDao extends DatabaseAccessor<AppDatabase> with _$BookDaoMixin {
  BookDao(super.attachedDatabase);

  Stream<BookInfoData?> watchBookInfo(int chapterId) {
    return (select(bookInfo)
          ..where((row) => row.chapterId.equals(chapterId)))
        .watchSingleOrNull();
  }

  Stream<List<BookChaptersTableData>> watchBookChapters(int chapterId) {
    return (select(bookChaptersTable)
          ..where((row) => row.chapterId.equals(chapterId))
          ..orderBy([(t) => OrderingTerm.asc(t.page)]))
        .watch();
  }

  Future<void> upsertBookInfo(BookInfoCompanion entry) async {
    await into(bookInfo).insertOnConflictUpdate(entry);
  }

  Future<void> upsertBookChapters(
    int chapterId,
    Iterable<BookChaptersTableCompanion> entries,
  ) async {
    await transaction(() async {
      await (delete(bookChaptersTable)
            ..where((row) => row.chapterId.equals(chapterId)))
          .go();
      await batch((b) => b.insertAll(bookChaptersTable, entries));
    });
  }
}
