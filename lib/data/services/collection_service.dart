import 'dart:convert';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/collection.dart';
import 'package:mycelium/data/services/api_service.dart';

class CollectionService {
  final ApiService api;
  CollectionService(this.api);

  Future<ApiResult<List<Collection>>> getCollections() async {
    final result = await api.get("/collections");

    if (result is ApiError) return result;

    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data);

    return ApiSuccess<List<Collection>>(
      (json["collections"] as List)
          .map((e) => Collection.fromJson(e))
          .toList(),
    );
  }

  Future<ApiResult<Collection>> createCollection(String name) async {
    final result = await api.post("/collections", {"name": name});

    if (result is ApiError) return result;

    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data);

    return ApiSuccess<Collection>(
      Collection.fromJson(json["collection"]),
    );
  }

  Future<ApiResult<void>> deleteCollection(int id) async {
    final result = await api.delete("/collections/$id");

    if (result is ApiError) return result;

    return ApiSuccess<void>(null);
  }

  Future<ApiResult<void>> renameCollection(int id, String newName) async {
    final result = await api.patch(
      "/collections/$id",
      {"newName": newName},
    );

    if (result is ApiError) return result;

    return ApiSuccess<void>(null);
  }
}
