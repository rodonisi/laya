import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/chapters.dart';
import 'package:fluvita/database/tables/continue_point.dart';
import 'package:fluvita/database/tables/series.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:stream_transform/stream_transform.dart';

part 'reader_dao.g.dart';

@DriftAccessor(tables: [Series, Chapters, ContinuePoints])
class ReaderDao extends DatabaseAccessor<AppDatabase> with _$ReaderDaoMixin {
  ReaderDao(super.attachedDatabase);

  Stream<Chapter> continuePoint({required int seriesId}) {
    final query = select(continuePoints).join([
      innerJoin(
        chapters,
        chapters.id.equalsExp(continuePoints.chapterId),
      ),
    ])..where(continuePoints.seriesId.equals(seriesId));

    // Ensure the watcher is listening to BOTH tables
    return query
        .watchSingleOrNull()
        .map((row) => row?.readTable(chapters))
        .whereNotNull();
  }

  Future<void> upsertContinuePoint(ContinuePointsCompanion entry) async {
    log.d('upsert continue point $entry');
    await into(continuePoints).insertOnConflictUpdate(entry);
  }
}
