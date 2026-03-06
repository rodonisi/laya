import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/riverpod_storage.dart';
import 'package:fluvita/riverpod/providers/settings/settings.dart';

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
