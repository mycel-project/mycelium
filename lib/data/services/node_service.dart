import 'dart:convert';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/models/node_type.dart';
import 'package:mycelium/data/services/api_service.dart';

class NodeService {
  final ApiService api;
  NodeService(this.api);

  Future<List<Node>> getNodes(int collectionId) async {
    final response = await api.get("/collections/$collectionId/nodes");
    if (response.statusCode != 200) throw Exception("Failed to load nodes");
    final List nodesJson = jsonDecode(response.body)["nodes"];
    return nodesJson.map((e) => Node.fromJson(e)).toList();
  }

  Future<List<NodeType>> getNodeTypes() async {
    final response = await api.get("/node-types");
    if (response.statusCode != 200) throw Exception("Failed to load node types");
    final List typesJson = jsonDecode(response.body)["types"];
    return typesJson.map((e) => NodeType.fromJson(e)).toList();
  }
}
