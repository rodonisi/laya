// import 'package:fluvita/models/image_model.dart';
// import 'package:fluvita/riverpod/providers/book.dart';
// import 'package:fluvita/riverpod/providers/chapter.dart';
// import 'package:fluvita/riverpod/providers/image.dart';
// import 'package:fluvita/riverpod/epub_page_content.dart';
// import 'package:fluvita/utils/logging.dart';
// import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
//
// part 'download_manager.freezed.dart';
// part 'download_manager.g.dart';
//
// enum DownloadStatus {
//   initial,
//   downloading,
//   completed,
// }
//
// @freezed
// sealed class DownloadManagerState with _$DownloadManagerState {
//   const DownloadManagerState._();
//
//   const factory DownloadManagerState.epub({
//     @Default(DownloadStatus.initial) DownloadStatus status,
//     @Default([]) List<PageContent> pages,
//     @Default(0) int totalPages,
//   }) = EpubDownloadManagerState;
//
//   const factory DownloadManagerState.image({
//     @Default(DownloadStatus.initial) DownloadStatus status,
//     @Default([]) List<ImageModel> pages,
//     @Default(0) int totalPages,
//   }) = ImageChapterDownloadManagerState;
//
//   factory DownloadManagerState.fromJson(Map<String, dynamic> json) =>
//       _$DownloadManagerStateFromJson(json);
//
//   double? get progress {
//     if (totalPages == 0) return null;
//     return pages.length / totalPages;
//   }
// }
//
// @riverpod
// class DownloadManager extends _$DownloadManager {
//   @override
//   Future<DownloadManagerState> build({
//     required int chapterId,
//   }) async {
//     if (state.value != null) return state.value!;
//
//     return _freshState;
//   }
//
//   Future<void> download() async {
//     if (state.value == null || state.value?.status == .downloading) {
//       return;
//     }
//
//     state = AsyncData(
//       state.value!.copyWith(
//         status: .downloading,
//       ),
//     );
//
//     final chapter = await ref.read(
//       chapterProvider(chapterId: chapterId).future,
//     );
//     final pageCount = chapter.pages;
//     if (pageCount == 0) {
//       throw Exception('Chapter has no pages to download.');
//     }
//
//     state = AsyncData(
//       state.value!.copyWith(
//         totalPages: pageCount,
//       ),
//     );
//
//     await state.value!.when(
//       epub: (status, pages, totalPages) async {
//         for (var i = 0; i < pageCount; i++) {
//           log.d('downloading page $i/$pageCount of chapter $chapterId');
//
//           final current = state.value as EpubDownloadManagerState;
//           final pageContent = await ref.read(
//             preprocessedPageProvider(
//               chapterId: chapterId,
//               page: i,
//             ).future,
//           );
//
//           state = AsyncData(
//             current.copyWith(pages: [...current.pages, pageContent]),
//           );
//         }
//       },
//       image: (status, pages, totalPages) async {
//         for (var i = 0; i < pageCount; i++) {
//           log.d('downloading page $i/$pageCount of chapter $chapterId');
//
//           final current = state.value as ImageChapterDownloadManagerState;
//           final pageContent = await ref.read(
//             readerImageProvider(
//               chapterId: chapterId,
//               page: i,
//             ).future,
//           );
//
//           state = AsyncData(
//             current.copyWith(pages: [...current.pages, pageContent]),
//           );
//         }
//       },
//     );
//
//     state = AsyncData(
//       state.value!.copyWith(
//         status: DownloadStatus.completed,
//       ),
//     );
//   }
//
//   Future<void> delete() async {
//     state = AsyncData(await _freshState);
//   }
//
//   Future<DownloadManagerState> get _freshState async {
//     final format = (await ref.read(
//       chapterProvider(chapterId: chapterId).future,
//     )).format;
//
//     return switch (format) {
//       .epub => const DownloadManagerState.epub(),
//       .archive => const DownloadManagerState.image(),
//       _ => throw Exception('unsupported format'),
//     };
//   }
// }
