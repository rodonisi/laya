// import 'package:fluvita/riverpod/download/download_manager.dart';
// import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
//
// part 'chapter_config.freezed.dart';
// part 'chapter_config.g.dart';
//
// @freezed
// sealed class ChapterConfigState with _$ChapterConfigState {
//   const ChapterConfigState._();
//   const factory ChapterConfigState({required bool download}) =
//       _ChapterConfigState;
//   factory ChapterConfigState.fromJson(Map<String, dynamic> json) =>
//       _$ChapterConfigStateFromJson(json);
// }
//
// @riverpod
// class ChapterConfig extends _$ChapterConfig {
//   @override
//   Future<ChapterConfigState> build({
//     required int seriesId,
//     required int chapterId,
//   }) async {
//     return const ChapterConfigState(download: false);
//   }
//
//   Future<void> setDownload(bool download) async {
//     final current = await future;
//
//     state = AsyncData(current.copyWith(download: download));
//     final notifier = ref.read(
//       downloadManagerProvider(
//         chapterId: chapterId,
//       ).notifier,
//     );
//
//     download ? await notifier.download() : await notifier.delete();
//   }
// }
