import 'dart:convert';

import 'package:mycelium/core/app_config.dart';
import 'package:mycelium/data/models/collection.dart';
import 'package:http/http.dart' as http;

class CollectionService {
  final AppConfig config;

  CollectionService(this.config);

  Future<List<Collection>> getCollections() async {
    final response = await http.get(
      Uri.parse("${config.baseUrl}/collections"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load collections");
    }

    final data = jsonDecode(response.body);

    final List collectionsJson = data["collections"];

    return collectionsJson.map((e) => Collection.fromJson(e)).toList();
  }

  Future<Collection> createCollection(String name) async {
    final response = await http.post(
      Uri.parse("${config.baseUrl}/collections"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
          "name": name,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to create collection");
    }

    final data = jsonDecode(response.body);

    final collectionJson = data["collection"];

    return Collection.fromJson(collectionJson);
  }


  Future<void> deleteCollection(int id) async {
    final response = await http.delete(
      Uri.parse("${config.baseUrl}/collections/$id"),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to delete collection");
    }
  }

  Future<void> renameCollection(int id, String newName) async {
    final response = await http.patch(
      Uri.parse("${config.baseUrl}/collections/$id"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
          "newName": newName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to rename collection");
    }
  }
}
