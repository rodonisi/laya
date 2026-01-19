import 'package:fluvita/models/user_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth.g.dart';

Duration? _retry(int retryCount, Object error) {
  if (retryCount >= 5) return null;

  return Duration(milliseconds: 200 * (1 << retryCount)); // Exponential backoff
}

@Riverpod(retry: _retry)
Future<UserModel> currentUser(Ref ref) async {
  final client = ref.watch(restClientProvider);
  final apiKey = ref.watch(apiKeyProvider);

  final user = await client.apiPluginAuthenticatePost(
    apiKey: apiKey ?? '',
    pluginName: 'fluvita',
  );

  return UserModel.fromUserDto(user);
}
