import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:kover/database/app_database.dart';
import 'package:kover/database/tables/riverpod_storage.dart';
import 'package:kover/riverpod/providers/settings/settings.dart';

part 'riverpod_dao.g.dart';

@DriftAccessor(
  tables: [RiverpodStorage],
)
class RiverpodDao extends DatabaseAccessor<AppDatabase>
    with _$RiverpodDaoMixin {
  RiverpodDao(super.attachedDatabase);

  Future<SettingsState?> getSettings() async {
    final settingsRow = await managers.riverpodStorage
        .filter((f) => f.key(Settings.settingsKey))
        .getSingleOrNull();

    if (settingsRow != null) {
      return SettingsState.fromJson(jsonDecode(settingsRow.data));
    }

    return null;
  }
}
