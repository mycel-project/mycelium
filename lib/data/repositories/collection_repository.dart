import 'dart:convert';

import 'package:mycelium/core/either.dart';
import 'package:mycelium/core/errors/collection_errors.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/collection.dart';
import 'package:mycelium/data/services/collection_service.dart';

class CollectionRepository {
  final CollectionService collectionService;

  final Map<int, Collection> _collectionCache = {};

  CollectionRepository(this.collectionService);

  Map<int, Collection> get collectionCache =>
      Map.unmodifiable(_collectionCache);

  void clearCache() {
    _collectionCache.clear();
  }

  Future<Either<CollectionError, Collection>> createCollection(
    String name,
  ) async {
    final result = await collectionService.createCollection(name);

    if (result is ApiError) {
      return Left(UnknownCollectionError(result.message));
    }

    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data);
    final collection = Collection.fromJson(json["collection"]);
    _collectionCache[collection.id] = collection;
    return Right(collection);
  }

  Future<Either<CollectionError, Collection>> renameCollection(
    int id,
    String newName,
  ) async {
    final result = await collectionService.renameCollection(id, newName);
    if (result is ApiError) {
      return Left(UnknownCollectionError(result.message));
    }

    final cached = _collectionCache[id];
    if (cached == null) {
      return Left(NotFoundCollectionError(id.toString()));
    }

    final updated = cached.copyWith(name: newName);
    _collectionCache[id] = updated;
    return Right(updated);
  }

  Future<Either<CollectionError, int>> deleteCollection(int id) async {
    final result = await collectionService.deleteCollection(id);

    if (result is ApiError) {
      return Left(UnknownCollectionError(result.message));
    }

    final cached = _collectionCache[id];
    if (cached == null) {
      return Left(NotFoundCollectionError(id.toString()));
    }

    _collectionCache.remove(id);
    return Right(id);
  }

  Future<ApiResult<List<Collection>>> loadCollections() async {
    final result = await collectionService.getCollections();

    if (result is ApiError) return result;

    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data);
    final collections = (json["collections"] as List)
        .map((e) => Collection.fromJson(e))
        .toList();
    _collectionCache.clear();
    for (final collection in collections) {
      _collectionCache[collection.id] = collection;
    }
    return ApiSuccess(collections);
  }
}
