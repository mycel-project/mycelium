import 'dart:convert';

import 'package:mycelium/core/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:mycelium/data/models/node.dart';

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
}
