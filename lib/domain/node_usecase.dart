import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/data/services/node_service.dart';
import 'package:mycelium/core/either.dart';

class NodeUseCase {
  NodeService nodeService;
  NodeStore nodeStore;
  NodeRepository nodeRepository;

  NodeUseCase(this.nodeService, this.nodeStore, this.nodeRepository);

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
          nodeStore.selectNode(node);
        },
      );
    }
  }

  void selectRootNode() async {
    final currentNode = nodeStore.currentNode;
    if (currentNode != null && currentNode.parentId != null) {
      final colId = currentNode.collectionId;
      final result = await nodeRepository.getRootNode(colId, currentNode.parentId!);
      result.fold(
        (error) {
          print("Can't get root node: $error");
        },
        (node) {
          nodeStore.selectNode(node);
        },
      );
    }
  }
}
