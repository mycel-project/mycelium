import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/navigation_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/domain/connection_status.dart';
import 'package:mycelium/domain/init_data_usecase.dart';

class AppCoordinator {
  final CollectionStore _collectionStore;
  final NodeRepository _nodeRepository;
  final NodeStore _nodeStore;
  final NavigationStore _navigationStore;
  final ApiStore _apiStore;
  final InitDataUseCase _initDataUseCase;
  bool _isDataInitialized = false;

  AppCoordinator(
    this._collectionStore,
    this._nodeRepository,
    this._nodeStore,
    this._navigationStore,
    this._apiStore,
    this._initDataUseCase,
  ) {
    _collectionStore.addListener(_onCollectionChanged);
    _apiStore.addListener(_onApiStatusChanged);
  }

  void _onApiStatusChanged() async {
    if (_apiStore.status == ConnectionStatus.connected && !_isDataInitialized) {
      await _initDataUseCase.execute();
      _isDataInitialized = true;
    }
  }

  void _onCollectionChanged() async {
    _nodeRepository.clearCache();
    _nodeRepository.clearOutlineCache();
    _nodeStore.selectNode(null);
    _navigationStore.clear();
    final colId = _collectionStore.currentCollection?.id;
    if (colId != null) {
      await _nodeRepository.loadNodes(colId);
    }
  }

  void dispose() {
    _collectionStore.removeListener(_onCollectionChanged);
    _apiStore.removeListener(_onApiStatusChanged);
  }
}
