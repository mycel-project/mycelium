import 'dart:convert';

import 'package:mycelium/core/either.dart';
import 'package:mycelium/core/errors/collection_errors.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/collection.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/services/collection_service.dart';

class CollectionRepository {
  final CollectionService collectionService;

  final Map<int, Collection> _collectionCache = {};

  CollectionRepository(this.collectionService);

  Map<int, Node> get collectionCache => Map.unmodifiable(_collectionCache);

  void clearCache() {
    _collectionCache.clear();
  }

  Future<Either<CollectionError, List<Collection>>> loadCollections(
  ) async {
    final result = await collectionService.getCollections();

    if (result is ApiError) {
      return Left(UnknownCollectionError(result.message));
    }
    
    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data);
    final collections = (json["collections"] as List).map((e) => Collection.fromJson(e)).toList();
    for (final collection in collections) {
      _collectionCache[collection.id] = collection;
    }    return Right(collections);
  }
}
