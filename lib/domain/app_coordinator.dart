import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/repositories/node_repository.dart';

/// Coordinates cross-cutting reactions to app-level state changes, such as invalidating caches, ...
class AppCoordinator {
  final CollectionStore _collectionStore;
  final NodeRepository _nodeRepository;
  final NodeStore _nodeStore;

  AppCoordinator(this._collectionStore, this._nodeRepository, this._nodeStore) {
    _collectionStore.addListener(_onCollectionChanged);
  }

  void _onCollectionChanged() async {
    _nodeRepository.clearCache();
    _nodeStore.selectNode(null);
    final colId = _collectionStore.currentCollection?.id;
    if (colId != null) {
      await _nodeRepository.loadNodes(colId);
    }
  }

  void dispose() {
    _collectionStore.removeListener(_onCollectionChanged);
  }
}
