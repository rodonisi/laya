import 'package:fluvita/models/user_model.dart';
import 'package:fluvita/riverpod/providers/client.dart';
import 'package:fluvita/riverpod/providers/settings/settings.dart';
import 'package:fluvita/riverpod/repository/storage_repository.dart';
import 'package:hooks_riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
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
@JsonPersist()
class CurrentUser extends _$CurrentUser {
  @override
  Future<UserModel> build() async {
    await persist(
      ref.watch(storageProvider.future),
      options: const StorageOptions(cacheTime: StorageCacheTime.unsafe_forever),
    ).future;

    final apiKey = ref.watch(apiKeyProvider);
    if (apiKey == null || apiKey.isEmpty) throw NoCredentialsException();

    try {
      final client = ref.watch(restClientProvider);
      final res = await client.apiPluginAuthenticatePost(
        apiKey: apiKey,
        pluginName: 'fluvita',
      );
      if (!res.isSuccessful || res.body == null) {
        throw Exception('Failed to authenticate: ${res.error}');
      }
      return UserModel.fromUserDto(res.body!);
    } catch (e) {
      if (state.hasValue) return state.value!;
      rethrow;
    }
  }
}
