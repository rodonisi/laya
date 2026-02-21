// import 'package:fluvita/models/image_model.dart';
// import 'package:fluvita/riverpod/providers/image.dart';
// import 'package:fluvita/riverpod/download/download_manager.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
//
// part 'image_page.g.dart';

//
// @riverpod
// Future<ImageModel> imagePage(
//   Ref ref, {
//   required int chapterId,
//   required int page,
// }) async {
//   final downloadState = await ref.watch(
//     downloadManagerProvider(chapterId: chapterId).future,
//   );
//
//   return downloadState.whenOrNull(
//         image: (status, pages, totalPages) {
//           if (status != .completed) return null;
//           return pages[page];
//         },
//       ) ??
//       await ref.watch(
//         readerImageProvider(chapterId: chapterId, page: page).future,
//       );
// }
