import 'package:kover/models/collection_model.dart';
import 'package:kover/models/enums/order_by_option.dart';
import 'package:kover/models/enums/sort_direction.dart';
import 'package:kover/models/image_model.dart';
import 'package:kover/riverpod/repository/collections_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collections.g.dart';

@riverpod
Stream<List<CollectionModel>> collections(
  Ref ref, {
  String query = '',
  UnorderedSortOption orderBy = .name,
  SortDirection direction = .ascending,
}) {
  final repository = ref.watch(collectionsRepositoryProvider);
  return repository.watchCollections(
    query: query,
    orderBy: orderBy,
    direction: direction,
  );
}

@riverpod
Stream<CollectionModel> collection(Ref ref, {required int collectionId}) {
  final repository = ref.watch(collectionsRepositoryProvider);
  return repository.watchCollection(collectionId).distinct();
}

@riverpod
Stream<ImageModel?> collectionCover(Ref ref, {required int collectionId}) {
  final repository = ref.watch(collectionsRepositoryProvider);
  return repository.watchCollectionCover(collectionId).distinct();
}
