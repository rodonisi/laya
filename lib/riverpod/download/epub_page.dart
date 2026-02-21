// import 'package:fluvita/riverpod/download/download_manager.dart';
// import 'package:fluvita/riverpod/epub_page_content.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
//
// part 'epub_page.g.dart';
//
// @riverpod
// Future<PageContent> epubPage(
//   Ref ref, {
//   required int seriesId,
//   required int chapterId,
//   required int page,
// }) async {
//   final downloadState = await ref.watch(
//     downloadManagerProvider(
//       chapterId: chapterId,
//     ).future,
//   );
//
//   return downloadState.whenOrNull(
//         epub: (status, pages, totalPages) {
//           if (status != .completed) return null;
//
//           return pages[page];
//         },
//       ) ??
//       ref.watch(
//         preprocessedPageProvider(
//           chapterId: chapterId,
//           page: page,
//         ).future,
//       );
// }
