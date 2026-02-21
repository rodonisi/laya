import 'package:fluvita/models/user_model.dart';
import 'package:fluvita/riverpod/providers/client.dart';
import 'package:fluvita/riverpod/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth.g.dart';

class NoCredentialsException implements Exception {}

Duration? _retry(int retryCount, Object error) {
  if (error is NoCredentialsException || retryCount >= 3) {
    return null;
  }

  return Duration(milliseconds: 200 * (1 << retryCount));
}

@Riverpod(retry: _retry)
Future<UserModel> currentUser(Ref ref) async {
  final client = ref.watch(restClientProvider);
  final apiKey = ref.watch(apiKeyProvider);

  if (apiKey == null || apiKey.isEmpty) {
    throw NoCredentialsException();
  }

  final res = await client.apiPluginAuthenticatePost(
    apiKey: apiKey,
    pluginName: 'fluvita',
  );

  if (!res.isSuccessful || res.body == null) {
    throw Exception('Failed to authenticate: ${res.error}');
  }

  return UserModel.fromUserDto(res.body!);
}
