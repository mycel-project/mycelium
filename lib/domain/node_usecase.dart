import 'package:mycelium/core/notifications/notification.dart';
import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node_data.dart';
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
          print("Can't get parent node: $error");
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
          print("Can't get root node: $error");
        },
        (node) {
          navigationUseCase.navigateTo(node.id);
        },
      );
    }
  }

  bool hasChildren(int nodeId) {
    // Only looking in cache because we suppose that if we have access to a node we have fetched its subtree
    return nodeRepository.nodeCache.values.any((n) => n.parentId == nodeId);
  }

  Future<String?> getNodeTitle(int colId, int nodeId) async {
    final result = await nodeRepository.getNode(colId, nodeId);
    return result.fold(
      (error) {
        print("Can't get node title: $error");
      },
      (node) {
        final title = node.data?.title;
        return title;
      },
    );
  }

  Future<void> deleteNode(int colId, int nodeId) async {
    final result = await nodeRepository.deleteNode(colId, nodeId);
    result.fold((err) {}, (deletedIds) {
      if (deletedIds.contains(nodeStore.currentNode?.id)) {
        nodeStore.selectNode(null);
      }
      navigationUseCase.onNodesDeleted(deletedIds);
    });
  }

  Future<Node?> updateNodeTitle(int colId, int nodeId, String title) async {
    final data = NodeUpdate(
      data: NodeData(title: title == "" ? null : title),
    ).toJson();
    final result = await nodeRepository.updateNode(colId, nodeId, data);

    switch (result) {
      case ApiSuccess(:final data):
        return data;
      case ApiError error:
        notificationBus.showError("Can't update node title", error);
        return null;
    }
  }
}
