import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:fluvita/database/dao/book_dao.dart';
import 'package:fluvita/database/dao/chapters_dao.dart';
import 'package:fluvita/database/dao/download_dao.dart';
import 'package:fluvita/database/dao/libraries_dao.dart';
import 'package:fluvita/database/dao/reader_dao.dart';
import 'package:fluvita/database/dao/series_dao.dart';
import 'package:fluvita/database/dao/series_metadata_dao.dart';
import 'package:fluvita/database/dao/storage_dao.dart';
import 'package:fluvita/database/dao/volumes_dao.dart';
import 'package:fluvita/database/tables/book_info.dart';
import 'package:fluvita/database/tables/chapters.dart';
import 'package:fluvita/database/tables/download.dart';
import 'package:fluvita/database/tables/libraries.dart';
import 'package:fluvita/database/tables/progress.dart';
import 'package:fluvita/database/tables/riverpod_storage.dart';
import 'package:fluvita/database/tables/series.dart';
import 'package:fluvita/database/tables/series_metadata.dart';
import 'package:fluvita/database/tables/volumes.dart';
import 'package:fluvita/database/tables/want_to_read.dart';
import 'package:fluvita/models/enums/format.dart';
import 'package:fluvita/models/enums/library_type.dart';
import 'package:fluvita/utils/safe_platform.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    RiverpodStorage,
    Libraries,
    Series,
    SeriesMetadata,
    SeriesCovers,
    People,
    Genres,
    Tags,
    SeriesPeopleRoles,
    SeriesGenres,
    SeriesTags,
    Volumes,
    VolumeCovers,
    Chapters,
    ChapterCovers,
    ReadingProgress,
    BookChaptersTable,
    WantToRead,
    DownloadedPages,
  ],
  daos: [
    StorageDao,
    LibrariesDao,
    SeriesDao,
    SeriesMetadataDao,
    VolumesDao,
    ChaptersDao,
    ReaderDao,
    BookDao,
    DownloadDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(series).go();
    });
  }

  static QueryExecutor _openConnection() {
    if (SafePlatform.isWeb) {
      return NativeDatabase.memory();
    }
    return driftDatabase(
      name: 'fluvita_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
        shareAcrossIsolates: true,
      ),
      // If you need web support, see https://drift.simonbinder.eu/platforms/web/
    );
  }
}
