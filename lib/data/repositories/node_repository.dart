import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node_type.dart';
import 'package:mycelium/data/services/node_service.dart';

class NodeRepository {
  final NodeService nodeService;

  Map<int, NodeType>? _typesCache;

  NodeRepository(this.nodeService);

  Future<Map<int, NodeType>> getNodeTypes() async {
    if (_typesCache != null) return _typesCache!;

    final result = await nodeService.getNodeTypes();

    if (result is ApiSuccess<List<NodeType>>) {
      _typesCache = {
        for (var type in result.data) type.key: type,
      };
      return _typesCache!;
    }

    throw Exception("Failed to load node types");
  }

  Future<NodeType?> getNodeType(int key) async {
    final types = await getNodeTypes();
    return types[key];
  }

  NodeType? getNodeTypeSync(int key) {
    return _typesCache?[key];
  }
}
