import 'package:chopper/chopper.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/riverpod/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client.g.dart';

@riverpod
ChopperClient authenticatedDio(Ref ref) {
  final settings = ref.watch(settingsProvider).value;
  final key = ref.watch(apiKeyProvider);

  if (settings?.url == null || settings?.apiKey == null) {
    throw Exception('Credentials not set in settings');
  }

  final uri = Uri.dataFromString(settings!.url!);
  final dio = ChopperClient(
    baseUrl: uri,
    interceptors: [
      HeadersInterceptor({
        'x-api-key': key!,
      }),
    ],
  );

  // dio.interceptors.add(
  //   InterceptorsWrapper(
  //     onRequest: (options, handler) async {
  //       if (key != null && key.isNotEmpty) {
  //         options.headers['x-api-key'] = key;
  //       }
  //       handler.next(options);
  //     },
  //   ),
  // );

  return dio;
}

@riverpod
Openapi restClient(Ref ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return Openapi.create(client: dio);
}
