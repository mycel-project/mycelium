import 'dart:convert';

import 'package:mycelium/core/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/models/node_type.dart';

class NodeService {
  final AppConfig config;

  NodeService(this.config);

  Future<List<Node>> getNodes(int collectionId) async {
    final response = await http.get(
      Uri.parse("${config.baseUrl}/collections/$collectionId/nodes"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load nodes");
    }

    final data = jsonDecode(response.body);

    final List nodesJson = data["nodes"];

    return nodesJson.map((e) => Node.fromJson(e)).toList();
  }

  Future<List<NodeType>> getNodeTypes() async {
    final response = await http.get(
      Uri.parse("${config.baseUrl}/node-types"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load node types");
    }

    final data = jsonDecode(response.body);

    final List typesJson = data["types"];

    return typesJson.map((e) => NodeType.fromJson(e)).toList();
  }
}
