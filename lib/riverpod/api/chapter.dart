import 'package:fluvita/models/chapter_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chapter.g.dart';

@riverpod
Future<ChapterModel> chapter(Ref ref, {required int chapterId}) async {
  final client = ref.watch(restClientProvider);
  final res = await client.apiChapterGet(chapterId: chapterId);
  
  if (!res.isSuccessful || res.body == null) {
    throw Exception('Failed to load chapter: ${res.error}');
  }

  return ChapterModel.fromChapterDto(res.body!);
}
