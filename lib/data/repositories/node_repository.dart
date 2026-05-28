import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:mycelium/core/either.dart';
import 'package:mycelium/core/errors/node_errors.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/models/node_type.dart';
import 'package:mycelium/data/models/outline_entry.dart';
import 'package:mycelium/data/services/node_service.dart';

class NodeRepository {
  // diff between load and get is that load always refetch (in theory, not strictly implemented like that yet)
  final NodeService nodeService;

  Map<int, NodeType>? _typesCache;
  final Map<int, Node> _nodeCache = {};
  (int, List<OutlineEntry>)? _outlineCache; // keeping only one node outline at a time to be sure to refresh when changin node. But is this necessary? a map could be an other way.

  NodeRepository(this.nodeService);

  Map<int, Node> get nodeCache => Map.unmodifiable(_nodeCache);
  Map<int, NodeType> get nodeTypesCache => Map.unmodifiable(_typesCache ?? {});

  List<OutlineEntry>? getOutlineCache(int nodeId) =>
    _outlineCache?.$1 == nodeId ? _outlineCache?.$2 : null;

  void clearCache() {
    _nodeCache.clear();
  }

  void clearTypesCache() {
    _typesCache = null;
  }

  void clearOutlineCache() {
    _outlineCache = null;
  }

  void updateCache(int id, Node node) {
    // When used from external access must be used in consequence of a fetch from backend, no direct modification from frontend. For example if review_repo get back a node and we want to store this node in cache, use this method.
    _nodeCache[id] = node;
  }

  Future<ApiResult<List<OutlineEntry>>> getOutline(int colId, int nodeId) async {
    final cached = getOutlineCache(nodeId);
    if (cached != null) return ApiSuccess(cached);
    return _loadOutline(colId, nodeId);
  }

  Future<ApiResult<List<OutlineEntry>>> _loadOutline(int colId, int nodeId) async {
    final result = await nodeService.getOutline(colId, nodeId);
    if (result is ApiError) return result;
    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data);
    final entries = (json["outline"]["entries"] as List? ?? [])
    .map((e) => OutlineEntry.fromJson(e))
    .toList();
    _outlineCache = (nodeId, entries);
    return ApiSuccess(entries);
  }

  Future<ApiResult<Node>> rescheduleNode(
    int colId,
    int nodeId,
    String dateIso,
    int tzOffset,
  ) async {
    final result = await nodeService.rescheduleNode(
      colId,
      nodeId,
      dateIso,
      tzOffset,
    );

    if (result is ApiError) return result;

    final success = result as ApiSuccess<String>;
    final node = _parseNode(success);
    _nodeCache[node.id] = node;
    return ApiSuccess(node);
  }

  Future<ApiResult<Node>> fetchRessourceFromUrl(
    int colId,
    String url,
    int tzOffset,
  ) async {
    final result = await nodeService.fetchRessourceFromUrl(
      colId,
      url,
      tzOffset,
    );

    if (result is ApiError) return result;

    final success = result as ApiSuccess<String>;
    final node = _parseNode(success);
    _nodeCache[node.id] = node;
    return ApiSuccess(node);
  }

  Future<ApiResult<List<Node>>> createExtract(
    int colId,
    int nodeId,
    String text,
    String field,
    int startIndex,
    int endIndex,
    int extractType,
    int tzOffset,
  ) async {
    final result = await nodeService.createExtract(
      colId,
      nodeId,
      text,
      field,
      startIndex,
      endIndex,
      extractType,
      tzOffset,
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

  Future<ApiResult<List<int>>> deleteNode(int colId, int nodeId) async {
    final result = await nodeService.deleteNode(colId, nodeId);

    if (result is ApiError) return result;
    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data);
    final deletedIds = (json["deleted_ids"] as List).cast<int>();
    for (final id in deletedIds) {
      _nodeCache.remove(id);
    }
    return ApiSuccess(deletedIds);
  }

  Future<ApiResult<Node>> reprioritiseNode(
    int colId,
    int nodeId,
    double priority,
  ) async {
    final result = await nodeService.reprioritiseNode(colId, nodeId, priority);
    if (result is ApiError) return result;
    final node = _parseNode(result as ApiSuccess<String>);
    _nodeCache[node.id] = node;
    return ApiSuccess(node);
  }

  Future<ApiResult<List<Node>>> splitNode(
    int collectionId,
    int nodeId,
    int level,
    int tzOffset,
  ) async {
    final result = await nodeService.splitNode(collectionId, nodeId, level, tzOffset);
    if (result is ApiError) return result;
    final nodes = _parseNodes(result as ApiSuccess<String>);
    for (final node in nodes) {
      _nodeCache[node.id] = node;
    }
    return ApiSuccess(nodes);
  }

  Future<ApiResult<void>> getPriorities(int colId) async {
    final result = await nodeService.getPriorities(colId);
    if (result is ApiError) return result;
    final json = jsonDecode((result as ApiSuccess<String>).data);
    final priorities = json["priorities"] as Map<String, dynamic>;
    for (final entry in priorities.entries) {
      final id = int.parse(entry.key);
      final node = _nodeCache[id];
      if (node != null) {
        _nodeCache[id] = node.copyWith(
          priority: double.parse((entry.value as double).toStringAsFixed(3)),
        );
      }
    }
    return ApiSuccess(null);
  }

  Future<ApiResult<List<Node>>> restoreNode(
    int colId,
    int nodeId,
    bool restoreAncestors,
    bool restoreDescendants,
  ) async {
    final result = await nodeService.restoreNode(
      colId,
      nodeId,
      restoreAncestors,
      restoreDescendants,
    );
    if (result is ApiError) return result;
    final nodes = _parseNodes(result as ApiSuccess<String>);
    for (final node in nodes) {
      _nodeCache[node.id] = node;
    }
    return ApiSuccess(nodes);
  }

  Node _parseNode(ApiSuccess<String> success) {
    final json = jsonDecode(success.data);
    return Node.fromJson(json["node"]);
  }

  List<Node> _parseNodes(ApiSuccess<String> success) {
    final json = jsonDecode(success.data);
    return (json["nodes"] as List).map((e) => Node.fromJson(e)).toList();
  }

  Future<ApiResult<List<Node>>> loadNodes(int colId) async {
    final result = await nodeService.getNodes(colId);
    if (result is ApiError) return result;
    final nodes = _parseNodes(result as ApiSuccess<String>);
    for (final node in nodes) {
      _nodeCache[node.id] = node;
    }
    return ApiSuccess(nodes);
  }

  Future<ApiResult<Node>> loadNode(int colId, int nodeId) async {
    final result = await nodeService.getNode(colId, nodeId);
    if (result is ApiError) return result;
    final node = _parseNode(result as ApiSuccess<String>);
    _nodeCache[node.id] = node;
    return ApiSuccess(node);
  }

  Future<ApiResult<List<Node>>> loadDeletedNodes(int colId) async {
    // No caching for deletedNodes at the moment
    final result = await nodeService.getDeletedNodes(colId);
    if (result is ApiError) return result;
    final nodes = _parseNodes(result as ApiSuccess<String>);
    return ApiSuccess(nodes);
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

  Future<ApiResult<Node>> removeLinks(
    int colId,
    int nodeId,
    String text,
    String field,
    int startIndex,
    int endIndex,
  ) async {
    final result = await nodeService.removeLinks(
      colId,
      nodeId,
      text,
      field,
      startIndex,
      endIndex,
    );
    if (result is ApiError) return result;
    final success = result as ApiSuccess<String>;
    final node = _parseNode(success);
    _nodeCache[node.id] = node;
    return ApiSuccess(node);
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
