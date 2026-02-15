import 'package:drift/drift.dart';

class PendingSyncOperations extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get operationType =>
      text()(); // 'mark_read', 'progress_update', etc.
  TextColumn get payload => text()(); // JSON data

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttempt => dateTime().nullable()();
}
