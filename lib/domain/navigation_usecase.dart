import 'package:mycelium/core/either.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/navigation_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/repositories/node_repository.dart';


/// Handles node navigation and history tracking. Use this instead of NodeStore directly when navigation should be recorded in history (in most cases).
class NavigationUseCase {
  final NodeRepository _nodeRepository;
  final NodeStore _nodeStore;
  final NavigationStore _navigationStore;
  final CollectionStore _collectionStore;

  NavigationUseCase(
    this._nodeRepository,
    this._nodeStore,
    this._navigationStore,
    this._collectionStore,
  );

  Future<void> navigateTo(int nodeId) async {
    final colId = _collectionStore.currentCollection?.id;
    if (colId == null) return;
    final result = await _nodeRepository.getNode(colId, nodeId);
    result.fold(
      (err) => null,
      (node) {
        _nodeStore.selectNode(node);
        _navigationStore.push(nodeId);
      },
    );
  }
}
