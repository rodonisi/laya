import 'package:fluvita/models/library_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library.g.dart';

@riverpod
class Library extends _$Library {
  @override
  Future<LibraryModel> build({required int libraryId}) async {
    final client = ref.watch(restClientProvider);
    final res = await client.apiLibraryGet(libraryId: libraryId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load library: ${res.error}');
    }

    return LibraryModel.fromLibraryDto(res.body!);
  }
}

@riverpod
class Libraries extends _$Libraries {
  @override
  Future<List<LibraryModel>> build() async {
    final client = ref.watch(restClientProvider);
    final res = await client.apiLibraryLibrariesGet();

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load libraries: ${res.error}');
    }

    return res.body!.map(LibraryModel.fromLibraryDto).toList();
  }
}
