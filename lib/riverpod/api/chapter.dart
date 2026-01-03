import 'package:laya/models/chapter_model.dart';
import 'package:laya/riverpod/api/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chapter.g.dart';

@riverpod
Future<ChapterModel> chapter(Ref ref, {required int chapterId}) async {
  final client = ref.watch(restClientProvider).chapter;
  final res = await client.getApiChapter(chapterId: chapterId);

  return ChapterModel.fromChapterDto(res);
}
