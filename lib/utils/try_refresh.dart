import 'package:fluvita/utils/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

Future<T?> tryRefresh<T>(FutureOr<T> Function() op) async {
  try {
    return await op();
  } catch (e) {
    log.e('refresh failure', error: e);
    return null;
  }
}
