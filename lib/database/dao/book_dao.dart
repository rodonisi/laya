import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/book_info.dart';
import 'package:fluvita/database/tables/chapters.dart';

part 'book_dao.g.dart';

@DriftAccessor(tables: [BookChaptersTable, Chapters])
class BookDao extends DatabaseAccessor<AppDatabase> with _$BookDaoMixin {
  BookDao(super.attachedDatabase);

  /// Watch TOC for [chapterId]
  Stream<List<BookChaptersTableData>> watchToc(int chapterId) {
    return (select(bookChaptersTable)
          ..where((row) => row.chapterId.equals(chapterId))
          ..orderBy([(t) => OrderingTerm.asc(t.page)]))
        .watch();
  }

  /// Returns the chapter ids for all chapters that can have a TOC but are
  /// missing one
  Future<List<int>> getMissingChapterIds() async {
    final query =
        select(chapters).join([
            leftOuterJoin(
              bookChaptersTable,
              bookChaptersTable.chapterId.equalsExp(chapters.id),
            ),
          ])
          ..where(
            chapters.format.equalsValue(.epub),
          )
          ..where(bookChaptersTable.chapterId.isNull());

    return await query.map((row) {
      return row.readTable(chapters).id;
    }).get();
  }

  /// Upsert TOC for [chapterId]
  Future<void> upsertToc(
    int chapterId,
    Iterable<BookChaptersTableCompanion> entries,
  ) async {
    await transaction(() async {
      await (delete(
        bookChaptersTable,
      )..where((row) => row.chapterId.equals(chapterId))).go();
      await batch((b) => b.insertAll(bookChaptersTable, entries));
    });
  }
}
