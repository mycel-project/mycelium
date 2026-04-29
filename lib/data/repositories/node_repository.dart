import 'dart:convert';

import 'package:mycelium/core/either.dart';
import 'package:mycelium/core/errors/node_fetch_errors.dart';
import 'package:mycelium/core/errors/node_update_errors.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/models/node_type.dart';
import 'package:mycelium/data/services/node_service.dart';

class NodeRepository {
  final NodeService nodeService;

  Map<int, NodeType>? _typesCache;
  final Map<int, Node> _nodeCache = {};

  NodeRepository(this.nodeService);

  Future<Either<NodeFetchError, Node>> _fetchNode(
    int colId,
    int nodeId,
    Future<ApiResult<String>> Function() call,
  ) async {
    if (_nodeCache.containsKey(nodeId)) {
      return Right(_nodeCache[nodeId]!);
    }
    final result = await call();
    if (result is ApiError) {
      if (result.code == "NODE_NOT_FOUND") {
        return Left(NodeNotFoundError(result.message));
      } else {
        return Left(UnknownNodeFetchError());
      }
    }
    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data);
    final node = Node.fromJson(json["node"]);
    _nodeCache[nodeId] = node;
    return Right(node);
  }

  Future<Either<NodeFetchError, Node>> getNode(int colId, int nodeId) =>
  _fetchNode(colId, nodeId, () => nodeService.getNode(colId, nodeId));

  Future<Either<NodeFetchError, Node>> fetchRoot(int colId, int nodeId) =>
  _fetchNode(colId, nodeId, () => nodeService.getRootNode(colId, nodeId));

  Future<Either<NodeFetchError, Node>> getRootNode(int colId, int nodeId) async {
    var currentId = nodeId;
    while (_nodeCache.containsKey(currentId)) {
      // Traverse the cache upwards to check whether the root node already exists
      final node = _nodeCache[currentId]!;
      if (node.parentId == null) return Right(node); 
      currentId = node.parentId!;
    }
    return fetchRoot(colId, currentId);
  }
  
  Future<Either<NodeUpdateError, Node>> updateNodeContent(
    int collectionId,
    int nodeId,
    String content,
  ) async {
    final result = await nodeService.saveNodeContent(
      collectionId,
      nodeId,
      content,
    );

    if (result is ApiError) {
      final error = result;

      if (error.code == "INVALID_NODE_UPDATE") {
        return Left(InvalidNodeUpdateError(error.message));
      }

      return Left(UnknownNodeUpdateError());
    }

    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data);

    return Right(Node.fromJson(json["node"]));
  }

  Future<Map<int, NodeType>> getNodeTypes() async {
    if (_typesCache != null) return _typesCache!;

    final result = await nodeService.getNodeTypes();

    if (result is ApiSuccess<List<NodeType>>) {
      _typesCache = {for (var type in result.data) type.key: type};
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
