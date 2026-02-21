import 'package:fluvita/models/library_model.dart';
import 'package:fluvita/riverpod/repository/libraries_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library.g.dart';

@riverpod
Stream<LibraryModel> library(Ref ref, {required int libraryId}) async* {
  final repo = ref.watch(librariesRepositoryProvider);
  yield* repo.watchLibrary(libraryId).distinct();
}

@riverpod
Stream<List<LibraryModel>> libraries(Ref ref) async* {
  final repo = ref.watch(librariesRepositoryProvider);
  yield* repo.watchLibraries().distinct();
}
