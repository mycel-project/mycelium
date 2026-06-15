import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/network/api_client.dart';

class NodeService {
  final ApiClient api;
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

  Future<ApiResult<String>> getPriorities(int collectionId) async {
    return await api.get("/collections/$collectionId/nodes/priorities");
  }

  Future<ApiResult<String>> getRootNode(int collectionId, int nodeId) async {
    return await api.get("/collections/$collectionId/nodes/$nodeId/root");
  }

  Future<ApiResult<String>> deleteNode(int collectionId, int nodeId) async {
    return await api.delete("/collections/$collectionId/nodes/$nodeId");
  }

  Future<ApiResult<String>> getOutline(int collectionId, int nodeId) async {
    return await api.get("/collections/$collectionId/nodes/$nodeId/outline");
  }
  
  Future<ApiResult<String>> reprioritiseNode(
    int collectionId,
    int nodeId,
    double priority,
  ) async {
    return await api.post(
      "/collections/$collectionId/nodes/$nodeId/reprioritise",
      {"priority": priority},
    );
  }

  Future<ApiResult<String>> rescheduleNode(
    int collectionId,
    int nodeId,
    String dateIso,
    int tzOffset,
  ) async {
    return await api.post(
      "/collections/$collectionId/nodes/$nodeId/reschedule",
      {
        "date": dateIso,
        "tz_offset": tzOffset,
      },
    );
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
    int tzOffset,
  ) async {
    return await api.post("/collections/$collectionId/nodes", {
      "type": "url",
      "url": url,
    },
    queryParams: {
      "tz_offset": tzOffset.toString()
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
    int tzOffset,
  ) async {
    return await api.post("/collections/$collectionId/nodes/$nodeId/extracts", {
      "text": text,
      "field": field,
      "start_index": startIndex,
      "end_index": endIndex,
      "extract_type": extractType,
      "tz_offset": tzOffset.toString(),
    });
  }

  Future<ApiResult<String>> removeLinks(
    int collectionId,
    int nodeId,
    String text,
    String field,
    int startIndex,
    int endIndex,
  ) async {
    return await api.post("/collections/$collectionId/nodes/$nodeId/remove-links", {
        "text": text,
        "field": field,
        "start_index": startIndex,
        "end_index": endIndex,
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
}
