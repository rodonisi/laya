import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluvita/riverpod/providers/auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity.g.dart';

@riverpod
/// Returns wheter a connection to the server can be established.
Stream<bool> hasConnection(Ref ref) {
  final user = ref.watch(currentUserProvider);

  return Connectivity().onConnectivityChanged.asyncMap((results) async {
    if (results.contains(ConnectivityResult.none) || user.hasError) {
      return false;
    }

    return true;
  });
}
