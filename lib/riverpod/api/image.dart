import 'package:fluvita/models/image_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image.g.dart';

@riverpod
class SeriesCover extends _$SeriesCover {
  @override
  Future<ImageModel> build({required int seriesId}) async {
    final client = ref.watch(restClientProvider);
    final key = ref.watch(apiKeyProvider);

    final res = await client.apiImageSeriesCoverGet(
      seriesId: seriesId,
      apiKey: key,
    );

    if (!res.isSuccessful) {
      throw Exception('Failed to load series cover: ${res.error}');
    }

    return ImageModel(data: res.bodyBytes);
  }
}

@riverpod
class ChapterCover extends _$ChapterCover {
  @override
  Future<ImageModel> build({required int chapterId}) async {
    final client = ref.watch(restClientProvider);
    final key = ref.watch(apiKeyProvider);

    final res = await client.apiImageChapterCoverGet(
      chapterId: chapterId,
      apiKey: key,
    );

    if (!res.isSuccessful) {
      throw Exception('Failed to load chapter cover: ${res.error}');
    }

    return ImageModel(data: res.bodyBytes);
  }
}

@riverpod
class VolumeCover extends _$VolumeCover {
  @override
  Future<ImageModel> build({required int volumeId}) async {
    final client = ref.watch(restClientProvider);
    final key = ref.watch(apiKeyProvider);

    final res = await client.apiImageVolumeCoverGet(
      volumeId: volumeId,
      apiKey: key,
    );

    if (!res.isSuccessful) {
      throw Exception('Failed to load volume cover: ${res.error}');
    }

    return ImageModel(data: res.bodyBytes);
  }
}

@riverpod
class LibraryCover extends _$LibraryCover {
  @override
  Future<ImageModel> build({required int libraryId}) async {
    final client = ref.watch(restClientProvider);
    final key = ref.watch(apiKeyProvider);

    final res = await client.apiImageLibraryCoverGet(
      libraryId: libraryId,
      apiKey: key,
    );

    if (!res.isSuccessful) {
      throw Exception('Failed to load library cover: ${res.error}');
    }

    return ImageModel(data: res.bodyBytes);
  }
}
