import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/collection.dart';
import 'package:mycelium/data/services/collection_service.dart';

import '../../../helpers/api_client_helper.dart';

void main() {
  late CollectionService service;

  setUp(() {
      service = CollectionService(createTestApiClient());
  });

  test('getCollections returns success', () async {
      final result = await service.getCollections();
      expect(result, isA<ApiSuccess>());
      final json = jsonDecode((result as ApiSuccess).data);
      expect(json["data"], isA<List>());
      final collections = (json["data"] as List)
      .map((e) => Collection.fromJson(e))
      .toList();
      expect(collections, isA<List<Collection>>());
  });

  test('createCollection returns success', () async {
      final result = await service.createCollection("Test");
      expect(result, isA<ApiSuccess>());
      final json = jsonDecode((result as ApiSuccess).data);
      final collection = Collection.fromJson(json["data"]);
      expect(collection, isA<Collection>());
  });

  test('deleteCollection returns success', () async {
      final result = await service.deleteCollection("123");
      expect(result, isA<ApiSuccess>());
  });

  test('renameCollection returns success', () async {
      final result = await service.renameCollection("123", "New Name");
      expect(result, isA<ApiSuccess>());
      final json = jsonDecode((result as ApiSuccess).data);
      final collection = Collection.fromJson(json["data"]);
      expect(collection, isA<Collection>());
  });
}
