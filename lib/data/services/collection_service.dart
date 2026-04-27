import 'dart:convert';
import 'package:mycelium/data/models/collection.dart';
import 'package:mycelium/data/services/api_service.dart';

class CollectionService {
  final ApiService api;
  CollectionService(this.api);

  Future<List<Collection>> getCollections() async {
    final response = await api.get("/collections");
    if (response.statusCode != 200) throw Exception("Failed to load collections");
    final List collectionsJson = jsonDecode(response.body)["collections"];
    return collectionsJson.map((e) => Collection.fromJson(e)).toList();
  }

  Future<Collection> createCollection(String name) async {
    final response = await api.post("/collections", {"name": name});
    if (response.statusCode != 200) throw Exception("Failed to create collection");
    return Collection.fromJson(jsonDecode(response.body)["collection"]);
  }

  Future<void> deleteCollection(int id) async {
    final response = await api.delete("/collections/$id");
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to delete collection");
    }
  }

  Future<void> renameCollection(int id, String newName) async {
    final response = await api.patch("/collections/$id", {"newName": newName});
    if (response.statusCode != 200) throw Exception("Failed to rename collection");
  }
}
