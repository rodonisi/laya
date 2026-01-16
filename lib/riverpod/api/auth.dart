import 'package:fluvita/api/export.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth.g.dart';

@riverpod
Future<UserDto> currentUser(Ref ref) async {
  final dio = ref.watch(authenticatedDioProvider);
  final client = RestClient(dio).plugin;
  final apiKey = ref.watch(apiKeyProvider);

  final user = await client.postApiPluginAuthenticate(
    apiKey: apiKey ?? '',
    pluginName: 'fluvita',
  );
  return user;
}
