import 'package:fluvita/database/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database.g.dart';

@riverpod
AppDatabase database(Ref ref) {
  return AppDatabase();
}
