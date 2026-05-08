import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:mycelium/core/either.dart';
import 'package:mycelium/core/errors/extract_errors.dart';
import 'package:mycelium/core/errors/node_errors.dart';
import 'package:mycelium/core/errors/node_update_errors.dart';
import 'package:mycelium/core/errors/ressource_error.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/models/node_type.dart';
import 'package:mycelium/data/services/node_service.dart';

class NodeRepository {
  final NodeService nodeService;

  Map<int, NodeType>? _typesCache;
  final Map<int, Node> _nodeCache = {};

  NodeRepository(this.nodeService);

  Map<int, Node> get nodeCache => Map.unmodifiable(_nodeCache);
  Map<int, NodeType> get nodeTypesCache => Map.unmodifiable(_typesCache ?? {});

  void clearCache() {
    _nodeCache.clear();
  }

  void clearTypesCache() {
    _typesCache = null;
  }

  Future<Either<RessourceError, Node>> fetchRessourceFromUrl(
    int colId,
    String url,
  ) async {
    final result = await nodeService.fetchRessourceFromUrl(colId, url);

    if (result is ApiError) {
      if (["UNKNOWN_RESSOURCE_TYPE", "INVALID_URL"].contains(result.code)) {
        return Left(UnprocessableResourceError(result.message));
      }
      return Left(UnknownRessourceError());
    }
    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data);
    final node = Node.fromJson(json["node"]);
    _nodeCache[node.id] = node;
    return Right(node);
  }

  Future<ApiResult<List<Node>>> createExtract(
    int colId,
    int nodeId,
    String text,
    String field,
    int startIndex,
    int endIndex,
    int extractType,
  ) async {
    final result = await nodeService.createExtract(
      colId,
      nodeId,
      text,
      field,
      startIndex,
      endIndex,
      extractType,
    );
    if (result is ApiError) return result;
    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data);
    final extractNode = Node.fromJson(json["extract_node"]);
    final sourceNode = Node.fromJson(json["source_node"]);
    _nodeCache[extractNode.id] = extractNode;
    _nodeCache[sourceNode.id] = sourceNode;
    return ApiSuccess([extractNode, sourceNode]);
  }

  Future<Either<NodeError, List<int>>> deleteNode(int colId, int nodeId) async {
    final result = await nodeService.deleteNode(colId, nodeId);

    if (result is ApiError) {
      if (result.code == "NODE_NOT_FOUND") {
        return Left(NodeNotFoundError(result.message));
      } else {
        return Left(UnknownNodeError());
      }
    }
    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data);
    final deletedIds = (json["deleted_ids"] as List).cast<int>();
    for (final id in deletedIds) {
      _nodeCache.remove(id);
    }
    return Right(deletedIds);
  }

  Future<Either<NodeError, List<Node>>> loadNodes(int colId) async {
    final result = await nodeService.getNodes(colId);
    if (result is ApiError) {
      if (result.code == "NODE_NOT_FOUND") {
        return Left(NodeNotFoundError(result.message));
      } else {
        return Left(UnknownNodeError());
      }
    }
    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data);
    final nodes = (json["nodes"] as List).map((e) => Node.fromJson(e)).toList();
    for (final node in nodes) {
      _nodeCache[node.id] = node;
    }
    return Right(nodes);
  }

  Future<Either<NodeError, Node>> _fetchNode(
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
        return Left(UnknownNodeError());
      }
    }
    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data);
    final node = Node.fromJson(json["node"]);
    _nodeCache[nodeId] = node;
    return Right(node);
  }

  Future<Either<NodeError, Node>> getNode(int colId, int nodeId) =>
      _fetchNode(colId, nodeId, () => nodeService.getNode(colId, nodeId));

  Future<Either<NodeError, Node>> fetchRoot(int colId, int nodeId) =>
      _fetchNode(colId, nodeId, () => nodeService.getRootNode(colId, nodeId));

  Future<Either<NodeError, Node>> getRootNode(int colId, int nodeId) async {
    var currentId = nodeId;
    while (_nodeCache.containsKey(currentId)) {
      // Traverse the cache upwards to check whether the root node already exists
      final node = _nodeCache[currentId]!;
      if (node.parentId == null) return Right(node);
      currentId = node.parentId!;
    }
    return fetchRoot(colId, currentId);
  }

  Future<ApiResult<Node>> _handleUpdateResult(
    ApiResult result,
    int nodeId,
  ) async {
    if (result is ApiError) return result;
    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data);
    final node = Node.fromJson(json["node"]);
    _nodeCache[nodeId] = node;
    return ApiSuccess(node);
  }

  Future<ApiResult<Node>> updateNodeContent(
    int collectionId,
    int nodeId,
    String content,
  ) async {
    final result = await nodeService.saveNodeContent(
      collectionId,
      nodeId,
      content,
    );
    return _handleUpdateResult(result, nodeId);
  }

  Future<ApiResult<Node>> updateNodeDismiss(
    int collectionId,
    int nodeId,
    bool dismiss,
  ) async {
    final result = await nodeService.updateNodeDismiss(
      collectionId,
      nodeId,
      dismiss,
    );
    return _handleUpdateResult(result, nodeId);
  }

  Future<ApiResult<Node>> updateNode(
    int collectionId,
    int nodeId,
    Map<String, dynamic> data,
  ) async {
    final result = await nodeService.updateNode(collectionId, nodeId, data);
    return _handleUpdateResult(result, nodeId);
  }

  Future<Either<NodeError, Map<int, NodeType>>> getNodeTypes() async {
    if (_typesCache != null) return Right(_typesCache!);
    final result = await nodeService.getNodeTypes();
    if (result is ApiError) {
      return Left(UnknownNodeError());
    }
    final success = result as ApiSuccess<List<NodeType>>;
    _typesCache = {for (var type in success.data) type.key: type};
    return Right(_typesCache!);
  }

  Future<Either<NodeError, NodeType>> getNodeType(int key) async {
    final result = await getNodeTypes();
    return result.fold(
      (err) => Left(err),
      (types) => types.containsKey(key)
          ? Right(types[key]!)
          : Left(NodeNotFoundError("NodeType $key not found")),
    );
  }

  NodeType? getNodeTypeSync(int key) => _typesCache?[key];

  NodeType? getNodeTypeByLabelSync(String label) =>
      _typesCache?.values.firstWhereOrNull((t) => t.label == label);
}
