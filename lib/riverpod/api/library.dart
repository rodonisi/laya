import 'package:fluvita/models/library_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library.g.dart';

@riverpod
Future<LibraryModel> library(Ref ref, {required int libraryId}) async {
  final client = ref.watch(restClientProvider);
  final res = await client.apiLibraryGet(libraryId: libraryId);

  if (!res.isSuccessful || res.body == null) {
    throw Exception('Failed to load library: ${res.error}');
  }

  return LibraryModel.fromLibraryDto(res.body!);
}

@riverpod
Future<List<LibraryModel>> libraries(Ref ref) async {
  final client = ref.watch(restClientProvider);
  final res = await client.apiLibraryLibrariesGet();

  if (!res.isSuccessful || res.body == null) {
    throw Exception('Failed to load libraries: ${res.error}');
  }

  return res.body!.map(LibraryModel.fromLibraryDto).toList();
}
