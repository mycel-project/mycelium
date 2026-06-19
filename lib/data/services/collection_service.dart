import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/network/api_client.dart';

class CollectionService {
  final ApiClient api;
  CollectionService(this.api);

  Future<ApiResult<String>> getCollections() async {
    return await api.get("/collections");
  }

  Future<ApiResult<String>> createCollection(String name) async {
    return await api.post("/collections", {"name": name});
  }

  Future<ApiResult<void>> deleteCollection(String id) async {
    return await api.delete("/collections/$id");
  }

  Future<ApiResult<void>> renameCollection(String id, String newName) async {
    return await api.patch("/collections/$id", {"name": newName});
  }
}
