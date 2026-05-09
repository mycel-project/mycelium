import 'dart:convert';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node_type.dart';
import 'package:mycelium/data/services/api_service.dart';

class NodeService {
  final ApiService api;
  NodeService(this.api);

  Future<ApiResult<String>> getNodes(int collectionId) async {
    return await api.get("/collections/$collectionId/nodes");
  }

  Future<ApiResult<String>> getDeletedNodes(int collectionId) async {
    return await api.get("/collections/$collectionId/nodes/deleted");
  }

  Future<ApiResult<String>> getNode(int collectionId, int nodeId) async {
    return await api.get("/collections/$collectionId/nodes/$nodeId");
  }

  Future<ApiResult<String>> getRootNode(int collectionId, int nodeId) async {
    return await api.get("/collections/$collectionId/nodes/$nodeId/root");
  }

  Future<ApiResult<String>> deleteNode(int collectionId, int nodeId) async {
    return await api.delete("/collections/$collectionId/nodes/$nodeId");
  }

  Future<ApiResult<String>> restoreNode(int collectionId, int nodeId, bool restoreAncestors, bool restoreDescendants) async {
    return await api.post(
      "/collections/$collectionId/nodes/$nodeId/restore",
      {
        "restore_ancestors":restoreAncestors,
        "restore_descendants":restoreDescendants,
      },
    );
  }

  Future<ApiResult<String>> fetchRessourceFromUrl(
    int collectionId,
    String url,
  ) async {
    return await api.post("/collections/$collectionId/nodes", {
      "type": "url",
      "url": url,
    });
  }

  Future<ApiResult<String>> updateNode(
    int collectionId,
    int nodeId,
    Map<String, dynamic> data,
  ) async {
    return await api.patch("/collections/$collectionId/nodes/$nodeId", data);
  }

  Future<ApiResult<String>> updateNodeDismiss(
    int collectionId,
    int nodeId,
    bool dismiss,
  ) async {
    return await api.patch("/collections/$collectionId/nodes/$nodeId", {
      "type_data": {"dismiss": dismiss},
    });
  }

  Future<ApiResult<String>> createExtract(
    int collectionId,
    int nodeId,
    String text,
    String field,
    int startIndex,
    int endIndex,
    int extractType,
  ) async {
    return await api.post("/collections/$collectionId/nodes/$nodeId/extracts", {
      "text": text,
      "field": field,
      "start_index": startIndex,
      "end_index": endIndex,
      "extract_type": extractType,
    });
  }

  Future<ApiResult<String>> saveNodeContent(
    int collectionId,
    int nodeId,
    String content,
  ) async {
    return api.patch("/collections/$collectionId/nodes/$nodeId", {
      "content": content,
    });
  }

  Future<ApiResult<List<NodeType>>> getNodeTypes() async {
    final result = await api.get("/config/node-types");

    if (result is ApiError) return result;

    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data);

    return ApiSuccess<List<NodeType>>(
      (json["types"] as List).map((e) => NodeType.fromJson(e)).toList(),
    );
  }
}
