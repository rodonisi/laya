import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluvita/riverpod/providers/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity.g.dart';

@riverpod
/// Returns wheter a connection to the server can be established.
Stream<bool> hasConnection(Ref ref) {
  final ping = ref.watch(pingProvider);

  return Connectivity().onConnectivityChanged.asyncMap((results) async {
    return !results.contains(ConnectivityResult.none) &&
        ping.hasValue &&
        ping.value!;
  });
}

@riverpod
Future<bool> ping(Ref ref) async {
  final client = ref.watch(restClientProvider);
  final res = await client.apiAccountRefreshAccountGet();
  return res.isSuccessful;
}
