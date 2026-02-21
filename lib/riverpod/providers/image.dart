import 'package:fluvita/models/image_model.dart';
import 'package:fluvita/riverpod/providers/client.dart';
import 'package:fluvita/riverpod/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image.g.dart';

@riverpod
class ReaderImage extends _$ReaderImage {
  @override
  Future<ImageModel> build({
    required int chapterId,
    required int page,
  }) async {
    final client = ref.watch(restClientProvider);
    final key = ref.watch(apiKeyProvider);

    final res = await client.apiReaderImageGet(
      chapterId: chapterId,
      page: page,
      apiKey: key,
    );

    if (!res.isSuccessful) {
      throw Exception('Failed to load reader image: ${res.error}');
    }

    return ImageModel(data: res.bodyBytes);
  }
}
