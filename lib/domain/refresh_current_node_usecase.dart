import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/repositories/node_repository.dart';

class RefreshCurrentNodeUseCase {
  // force refetch of current node without updating nodeStore
  final NodeRepository nodeRepository;
  final NodeStore nodeStore;
  final CollectionStore collectionStore;

  RefreshCurrentNodeUseCase(
    this.nodeRepository,
    this.nodeStore,
    this.collectionStore,
  );

  Future<Node?> execute() async {
    final colId = collectionStore.currentCollection?.id;
    final node = nodeStore.currentNode;
    if (colId == null || node == null) return null;
    final result = await nodeRepository.loadNode(colId, node.id);
    switch (result) {
      case ApiSuccess(:final data):
        return data;
      case ApiError():
    }
    return null;
  }
}
