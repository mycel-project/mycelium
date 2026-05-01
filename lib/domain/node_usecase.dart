import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/data/services/node_service.dart';
import 'package:mycelium/core/either.dart';
import 'package:mycelium/domain/navigation_usecase.dart';

class NodeUseCase {
  NodeService nodeService;
  NodeStore nodeStore;
  NodeRepository nodeRepository;
  NavigationUseCase navigationUseCase;

  NodeUseCase(
    this.nodeService,
    this.nodeStore,
    this.nodeRepository,
    this.navigationUseCase,
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
    return nodeRepository.nodeCache.values
    .any((n) => n.parentId == nodeId);
  }
}
