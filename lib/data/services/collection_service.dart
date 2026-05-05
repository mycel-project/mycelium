import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/services/api_service.dart';

class CollectionService {
  final ApiService api;
  CollectionService(this.api);

  Future<ApiResult<String>> getCollections() async {
    return await api.get("/collections");
  }

  Future<ApiResult<String>> createCollection(String name) async {
    return await api.post("/collections", {"name": name});
  }

  Future<ApiResult<void>> deleteCollection(int id) async {
    return await api.delete("/collections/$id");
  }

  Future<ApiResult<void>> renameCollection(int id, String newName) async {
    return await api.patch("/collections/$id", {"newName": newName});
  }
}
