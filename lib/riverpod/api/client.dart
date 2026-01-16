import 'package:dio/dio.dart';
import 'package:fluvita/api/rest_client.dart';
import 'package:fluvita/riverpod/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client.g.dart';

@riverpod
Dio authenticatedDio(Ref ref) {
  final dio = Dio();
  final settings = ref.watch(settingsProvider).value;
  final key = ref.watch(apiKeyProvider);

  if (settings?.url != null) {
    dio.options.baseUrl = settings!.url!;
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (key != null && key.isNotEmpty) {
          options.headers['x-api-key'] = key;
        }
        handler.next(options);
      },
    ),
  );

  return dio;
}

@riverpod
RestClient restClient(Ref ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return RestClient(dio);
}
