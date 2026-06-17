import 'dart:convert';

import 'package:mycelium/core/either.dart';
import 'package:mycelium/core/errors/node_errors.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/models/outline_entry.dart';
import 'package:mycelium/data/services/node_service.dart';

class NodeRepository {
  // diff between load and get is that load always refetch (in theory, not strictly implemented like that yet)
  final NodeService nodeService;

  final Map<String, Node> _nodeCache = {};
  (String, List<OutlineEntry>)?
  _outlineCache; // keeping only one node outline at a time to be sure to refresh when changin node. But is this necessary? a map could be an other way.

  NodeRepository(this.nodeService);

  Map<String, Node> get nodeCache => Map.unmodifiable(_nodeCache);

  List<OutlineEntry>? getOutlineCache(String nodeId) =>
      _outlineCache?.$1 == nodeId ? _outlineCache?.$2 : null;

  void clearCache() {
    _nodeCache.clear();
  }

  void clearOutlineCache() {
    _outlineCache = null;
  }

  void updateCache(String id, Node node) {
    // When used from external access must be used in consequence of a fetch from backend, no direct modification from frontend. For example if review_repo get back a node and we want to store this node in cache, use this method.
    _nodeCache[id] = node;
  }

  Future<ApiResult<List<OutlineEntry>>> getOutline(
    String colId,
    String nodeId,
  ) async {
    final cached = getOutlineCache(nodeId);
    if (cached != null) return ApiSuccess(cached);
    return _loadOutline(colId, nodeId);
  }

  Future<ApiResult<List<OutlineEntry>>> _loadOutline(
    String colId,
    String nodeId,
  ) async {
    final result = await nodeService.getOutline(colId, nodeId);
    if (result is ApiError) return result;
    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data);
    final entries = (json["data"]["entries"] as List? ?? [])
        .map((e) => OutlineEntry.fromJson(e))
        .toList();
    _outlineCache = (nodeId, entries);
    return ApiSuccess(entries);
  }

  Future<ApiResult<Node>> rescheduleNode(
    String colId,
    String nodeId,
    String dateIso,
    int tzOffset,
    int slot,
  ) async {
    final result = await nodeService.reschedule(
      colId,
      nodeId,
      dateIso,
      tzOffset,
      slot,
    );

    if (result is ApiError) return result;

    final success = result as ApiSuccess<String>;
    final node = _parseNode(success);
    _nodeCache[node.id] = node;
    return ApiSuccess(node);
  }

  Future<ApiResult<Node>> fetchRessourceFromUrl(
    String colId,
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
    String colId,
    String nodeId,
    String text,
    String field,
    int startIndex,
    int endIndex,
    String extractType,
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
    final json = jsonDecode(success.data)["data"];
    final extractNode = Node.fromJson(json["extract_node"]);
    final sourceNode = Node.fromJson(json["source_node"]);
    _nodeCache[extractNode.id] = extractNode;
    _nodeCache[sourceNode.id] = sourceNode;
    return ApiSuccess([extractNode, sourceNode]);
  }

  Future<ApiResult<List<String>>> deleteNode(
    String colId,
    String nodeId,
  ) async {
    final result = await nodeService.deleteNode(colId, nodeId);

    if (result is ApiError) return result;
    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data)["data"];
    final deletedIds = (json["deleted_ids"] as List).cast<String>();
    for (final id in deletedIds) {
      _nodeCache.remove(id);
    }
    return ApiSuccess(deletedIds);
  }

  Future<ApiResult<Node>> reprioritiseNode(
    String colId,
    String nodeId,
    double priority,
    int slot,
  ) async {
    final result = await nodeService.reprioritise(colId, nodeId, priority, slot);
    if (result is ApiError) return result;
    final node = _parseNode(result as ApiSuccess<String>);
    _nodeCache[node.id] = node;
    return ApiSuccess(node);
  }

  Future<ApiResult<void>> getPriorities(String colId) async {
    final result = await nodeService.getPriorities(colId);
    if (result is ApiError) return result;

    final json = jsonDecode((result as ApiSuccess<String>).data);
    
    for (final entry in json["data"] as List) {
      final node = _nodeCache[entry["node_id"]];
      if (node == null) continue;

      final slot = entry["slot"] as int;
      final priority = (entry["priority"] as num).toDouble();

      // Assumes that slot counts are zero-indexed and sequential (+1).
      // If this changes, do not use [slot] directly; look up the actual index 
      // of the slot within the node's list instead.
      if (slot < node.priorities.length) {
        node.priorities[slot] = priority;
      }

      if (node.learningUnits != null && slot < node.learningUnits!.length) {
        node.learningUnits![slot] = switch (node.learningUnits![slot]) {
          Fragment f => f.copyWith(unit: f.unit.copyWith(priority: priority)),
          Spore s => s.copyWith(unit: s.unit.copyWith(priority: priority)),
        };
      }
    }
    return ApiSuccess(null);
  }

  Future<ApiResult<List<Node>>> restoreNode(
    String colId,
    String nodeId,
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
    final json = jsonDecode(success.data)["data"];
    return Node.fromJson(json);
  }

  List<Node> _parseNodes(ApiSuccess<String> success) {
    final json = jsonDecode(success.data)["data"];
    return (json as List).map((e) => Node.fromJson(e)).toList();
  }

  Future<ApiResult<List<Node>>> loadNodes(String colId) async {
    final result = await nodeService.getNodes(colId);
    if (result is ApiError) return result;
    final nodes = _parseNodes(result as ApiSuccess<String>);
    for (final node in nodes) {
      _nodeCache[node.id] = node;
    }
    return ApiSuccess(nodes);
  }

  Future<ApiResult<Node>> loadNode(String colId, String nodeId) async {
    final result = await nodeService.getNode(colId, nodeId);
    if (result is ApiError) return result;
    final node = _parseNode(result as ApiSuccess<String>);
    _nodeCache[node.id] = node;
    return ApiSuccess(node);
  }

  Future<ApiResult<List<Node>>> loadDeletedNodes(String colId) async {
    // No caching for deletedNodes at the moment
    final result = await nodeService.getDeletedNodes(colId);
    if (result is ApiError) return result;
    final nodes = _parseNodes(result as ApiSuccess<String>);
    return ApiSuccess(nodes);
  }

  Future<Either<NodeError, Node>> _fetchNode(
    String colId,
    String nodeId,
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
    final json = jsonDecode(success.data)["data"];
    final node = Node.fromJson(json);
    _nodeCache[nodeId] = node;
    return Right(node);
  }

  Future<Either<NodeError, Node>> getNode(String colId, String nodeId) =>
      _fetchNode(colId, nodeId, () => nodeService.getNode(colId, nodeId));

  Future<Either<NodeError, Node>> fetchRoot(String colId, String nodeId) =>
      _fetchNode(colId, nodeId, () => nodeService.getRootNode(colId, nodeId));

  Future<Either<NodeError, Node>> getRootNode(
    String colId,
    String nodeId,
  ) async {
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
    String nodeId,
  ) async {
    if (result is ApiError) return result;
    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data)["data"];
    final node = Node.fromJson(json);
    _nodeCache[nodeId] = node;
    return ApiSuccess(node);
  }

  Future<ApiResult<Node>> updateNodeContent(
    String collectionId,
    String nodeId,
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
    String collectionId,
    String nodeId,
    bool dismiss,
  ) async {
    final result = await nodeService.updateNodeDismiss(
      collectionId,
      nodeId,
      value: dismiss,
    );
    return _handleUpdateResult(result, nodeId);
  }

  Future<ApiResult<Node>> updateNode(
    String collectionId,
    String nodeId,
    Map<String, dynamic> data,
  ) async {
    final result = await nodeService.updateNode(collectionId, nodeId, data);
    return _handleUpdateResult(result, nodeId);
  }

  Future<ApiResult<Node>> removeLinks(
    String colId,
    String nodeId,
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
}
