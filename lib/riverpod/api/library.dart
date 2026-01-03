import 'package:laya/models/library_model.dart';
import 'package:laya/riverpod/api/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library.g.dart';

@riverpod
Future<List<LibraryModel>> libraries(Ref ref) async {
  final client = ref.watch(restClientProvider).library;
  final res = await client.getApiLibraryLibraries();

  return res.map(LibraryModel.fromLibraryDto).toList();
}
