import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/chapters.dart';
import 'package:fluvita/database/tables/download.dart';
import 'package:fluvita/database/tables/libraries.dart';

part 'download_dao.g.dart';

@DriftAccessor(tables: [EpubPages, ImagePages, Chapters])
class DownloadDao extends DatabaseAccessor<AppDatabase>
    with _$DownloadDaoMixin {
  DownloadDao(super.attachedDatabase);
}
