import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/riverpod/providers/client.dart';
import 'package:fluvita/riverpod/repository/reader_repository.dart';
import 'package:fluvita/sync/reader_sync_operations.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:fluvita/utils/safe_platform.dart';
import 'package:workmanager/workmanager.dart';

const String _periodicTaskId = 'com.rodonisi.fluvita.periodic_task';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    final db = AppDatabase();
    try {
      final settings = await db.storageDao.getSettings();
      if (settings == null) return false;

      final chopper = getChopperClient(
        Uri.parse(settings.url!),
        settings.apiKey!,
      );

      final syncOps = ReaderSyncOperations(
        client: Openapi.create(client: chopper),
      );
      final repo = ReaderRepository(db, syncOps);
      await repo.mergeProgress();

      log.d('succesfully merged progress');

      return true;
    } catch (e) {
      log.e('failed background fetch', error: e);
    } finally {
      db.close();
    }

    return false;
  });
}

Future<void> initializeBackgroundTask() async {
  if (SafePlatform.isIOS || SafePlatform.isAndroid) {
    await Workmanager().initialize(
      callbackDispatcher,
    );

    await Workmanager().registerPeriodicTask(
      _periodicTaskId,
      _periodicTaskId,
      frequency: 1.hours,
      flexInterval: 1.hours,
      initialDelay: 5.minutes,
      existingWorkPolicy: .keep,
      backoffPolicy: .exponential,
      constraints: Constraints(
        networkType: .connected,
        requiresBatteryNotLow: true,
      ),
    );
  }
}
