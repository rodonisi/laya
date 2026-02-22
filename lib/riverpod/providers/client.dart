import 'package:chopper/chopper.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/riverpod/providers/settings/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client.g.dart';

@riverpod
ChopperClient authenticatedClient(Ref ref) {
  final settings = ref.watch(settingsProvider).value;
  final key = ref.watch(apiKeyProvider);

  if (settings?.url == null || settings?.apiKey == null) {
    throw Exception('Credentials not set in settings');
  }

  final uri = Uri.tryParse(settings!.url!);
  if (uri == null) {
    throw Exception('Invalid URL in settings');
  }

  final client = ChopperClient(
    baseUrl: uri,
    interceptors: [
      HeadersInterceptor({
        'x-api-key': key!,
        "Content-Type": "application/json",
      }),
    ],
    converter: $JsonSerializableConverter(),
  );

  return client;
}

@riverpod
Openapi restClient(Ref ref) {
  final client = ref.watch(authenticatedClientProvider);
  return Openapi.create(client: client);
}
