import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/network/api_client.dart';

class NodeService {
  final ApiClient api;
  NodeService(this.api);

  Future<ApiResult<String>> getNodes(String collectionId) async {
    return await api.get("/collections/$collectionId/nodes");
  }

  Future<ApiResult<String>> getDeletedNodes(String collectionId) async {
    return await api.get("/collections/$collectionId/nodes/deleted");
  }

  Future<ApiResult<String>> getNode(String collectionId, String nodeId) async {
    return await api.get("/collections/$collectionId/nodes/$nodeId");
  }

  Future<ApiResult<String>> getPriorities(String collectionId) async {
    return await api.get("/collections/$collectionId/nodes/priorities");
  }

  Future<ApiResult<String>> getRootNode(String collectionId, String nodeId) async {
    return await api.get("/collections/$collectionId/nodes/$nodeId/root");
  }

  Future<ApiResult<String>> deleteNode(String collectionId, String nodeId) async {
    return await api.delete("/collections/$collectionId/nodes/$nodeId");
  }

  Future<ApiResult<String>> getOutline(String collectionId, String nodeId) async {
    return await api.get("/collections/$collectionId/nodes/$nodeId/outline");
  }

  Future<ApiResult<String>> splitNode(
    String collectionId,
    String nodeId,
    int level,
    int tzOffset,
    int slot,
  ) async {
    return await api.post(
      "/collections/$collectionId/nodes/$nodeId/split",
      {},
      queryParams: {"level": level.toString(), "tz_offset": tzOffset.toString()},
    );
  }
  
  Future<ApiResult<String>> reprioritise(
    String collectionId,
    String nodeId,
    double priority,
    int slot,
  ) async {
    return await api.patch(
      "/collections/$collectionId/nodes/$nodeId/slot/$slot/reprioritise",
      {"priority": priority},
    );
  }

  Future<ApiResult<String>> reschedule(
    String collectionId,
    String nodeId,
    String dateIso,
    int tzOffset,
    int slot,
  ) async {
    return await api.patch(
      "/collections/$collectionId/nodes/$nodeId/slot/$slot/reschedule",
      {
        "date": dateIso,
        "tz_offset": tzOffset,
      },
    );
  }

  Future<ApiResult<String>> restoreNode(String collectionId, String nodeId, bool restoreAncestors, bool restoreDescendants) async {
    return await api.post(
      "/collections/$collectionId/nodes/$nodeId/restore",
      {
        "restore_ancestors":restoreAncestors,
        "restore_descendants":restoreDescendants,
      },
    );
  }

  Future<ApiResult<String>> fetchRessourceFromUrl(
    String collectionId,
    String url,
    int tzOffset,
  ) async {
    return await api.post("/collections/$collectionId/nodes", {
        "type": "url",
        "url": url,
        "tz_offset": tzOffset
    });
  }

  Future<ApiResult<String>> updateNode(
    String collectionId,
    String nodeId,
    Map<String, dynamic> data,
  ) async {
    return await api.patch("/collections/$collectionId/nodes/$nodeId", data);
  }

  Future<ApiResult<String>> updateNodeDismiss(
    String collectionId,
    String nodeId, {
      bool? value,
  }) async {
    return await api.patch(
      "/collections/$collectionId/nodes/$nodeId/slot/0/dismiss",
      value != null ? {"value": value} : {},
    );
  }

  Future<ApiResult<String>> createExtract(
    String collectionId,
    String nodeId,
    String text,
    String field,
    int startIndex,
    int endIndex,
    String extractType,
    int tzOffset,
  ) async {
    return await api.post("/collections/$collectionId/nodes/$nodeId/extracts", {
      "text": text,
      "field": field,
      "start_index": startIndex,
      "end_index": endIndex,
      "extract_type": extractType,
      "tz_offset": tzOffset,
    });
  }

  Future<ApiResult<String>> removeLinks(
    String collectionId,
    String nodeId,
    String text,
    String field,
    int startIndex,
    int endIndex,
  ) async {
    return await api.post(
      "/collections/$collectionId/nodes/$nodeId/remove-links",
      {
        "text": text,
        "field": field,
        "start_index": startIndex,
        "end_index": endIndex,
      },
    );
  }

  Future<ApiResult<String>> saveNodeContent(
    String collectionId,
    String nodeId,
    Map fields,
  ) async {
    return api.patch("/collections/$collectionId/nodes/$nodeId", {
      "fields": fields,
    });
  }
}
