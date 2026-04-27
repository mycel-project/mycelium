import 'dart:convert';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/models/node_type.dart';
import 'package:mycelium/data/services/api_service.dart';

class NodeService {
  final ApiService api;
  NodeService(this.api);

  Future<ApiResult<List<Node>>> getNodes(int collectionId) async {
    final result = await api.get("/collections/$collectionId/nodes");

    if (result is ApiError) return result;

    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data);

    return ApiSuccess<List<Node>>(
      (json["nodes"] as List).map((e) => Node.fromJson(e)).toList(),
    );
  }

  Future<ApiResult<Node>> saveNodeContent(
    int collectionId,
    int nodeId,
    String content,
  ) async {
    final result = await api.patch("/collections/$collectionId/nodes/$nodeId", {"content": content});

    if (result is ApiError) return result;

    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data);

    return ApiSuccess<Node>(
      Node.fromJson(json["node"]),
    );
  }

  Future<ApiResult<List<NodeType>>> getNodeTypes() async {
    final result = await api.get("/node-types");

    if (result is ApiError) return result;

    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data);

    return ApiSuccess<List<NodeType>>(
      (json["types"] as List).map((e) => NodeType.fromJson(e)).toList(),
    );
  }
}
