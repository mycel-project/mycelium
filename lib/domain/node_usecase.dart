import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node_update.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/data/services/node_service.dart';
import 'package:mycelium/core/either.dart';
import 'package:mycelium/domain/navigation_usecase.dart';
import 'package:mycelium/data/models/node.dart';

class NodeUseCase {
  NodeService nodeService;
  NodeStore nodeStore;
  NodeRepository nodeRepository;
  NavigationUseCase navigationUseCase;
  NotificationBus notificationBus;

  NodeUseCase(
    this.nodeService,
    this.nodeStore,
    this.nodeRepository,
    this.navigationUseCase,
    this.notificationBus,
  );

  void selectParentNode() async {
    final currentNode = nodeStore.currentNode;
    if (currentNode != null && currentNode.parentId != null) {
      final colId = currentNode.collectionId;
      final result = await nodeRepository.getNode(colId, currentNode.parentId!);
      result.fold(
        (error) {
          notificationBus.showError("Can't get parent node: $error");
        },
        (node) {
          navigationUseCase.navigateTo(node.id);
        },
      );
    }
  }

  void selectRootNode() async {
    final currentNode = nodeStore.currentNode;
    if (currentNode != null && currentNode.parentId != null) {
      final colId = currentNode.collectionId;
      final result = await nodeRepository.getRootNode(
        colId,
        currentNode.parentId!,
      );
      result.fold(
        (error) {
          notificationBus.showError("Can't get root node: $error");
        },
        (node) {
          navigationUseCase.navigateTo(node.id);
        },
      );
    }
  }

  bool hasChildren(String nodeId) {
    // Only looking in cache because we suppose that if we have access to a node we have fetched its subtree
    return nodeRepository.nodeCache.values.any((n) => n.parentId == nodeId);
  }

  Future<String?> getNodeTitle(String colId, String nodeId) async {
    final result = await nodeRepository.getNode(colId, nodeId);
    return result.fold(
      (error) {
        notificationBus.showWarning("Can't get node title: $error");
        return null;
      },
      (node) {
        final title = node.data?["title"];
        return title;
      },
    );
  }

  Future<bool> deleteNode(String colId, String nodeId) async {
    /// return false if error during delete
    final result = await nodeRepository.deleteNode(colId, nodeId);

    switch (result) {
      case ApiSuccess(:final data):
        final deletedIds = data;
        if (deletedIds.contains(nodeStore.currentNode?.id)) {
          nodeStore.selectNode(null);
        }
        navigationUseCase.onNodesDeleted(deletedIds);
        return true;
      case ApiError error:
        notificationBus.showError("Can't delete node", error);
    }
    return false;
  }

  Future<Node?> updateNodeTitle(
    String colId,
    String nodeId,
    String title,
  ) async {
    final data = NodeUpdate(data: {title: title == "" ? null : title}).toJson();
    final result = await nodeRepository.updateNode(colId, nodeId, data);

    switch (result) {
      case ApiSuccess(:final data):
        return data;
      case DomainError error:
        notificationBus.showError("Can't update node title", error);
    }
    return null;
  }
}
