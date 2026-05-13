import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/navigation_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/domain/api_status.dart';
import 'package:mycelium/domain/init_data_usecase.dart';
import 'package:mycelium/domain/api_compatibility.dart';

/// Coordinates cross-cutting reactions to app-level state changes, such as invalidating caches, fetching global data if init in main has failed ... without notifying
class AppCoordinator {
  final CollectionStore _collectionStore;
  final NodeRepository _nodeRepository;
  final NodeStore _nodeStore;
  final NavigationStore _navigationStore;
  final ApiStore _apiStore;
  final InitDataUseCase _initDataUseCase;
  bool _isDataInitialized = false;
  final NotificationBus _notificationBus;

  AppCoordinator(
    this._collectionStore,
    this._nodeRepository,
    this._nodeStore,
    this._navigationStore,
    this._apiStore,
    this._initDataUseCase,
    this._notificationBus,
  ) {
    _collectionStore.addListener(_onCollectionChanged);
    _apiStore.addListener(_onApiStatusChanged);
  }

  void _onApiStatusChanged() async {
    if (_apiStore.status == ApiStatus.reachable && !_isDataInitialized) {
      await _initDataUseCase.execute();
      _isDataInitialized = true;
    }

    if (_apiStore.status == ApiStatus.reachable) {
      switch (_apiStore.apiCompatibility) {
        case ApiCompatibility.incompatible:
        _notificationBus.showWarning(
          "Mycel version is not compatible. See Mycelium repository (compatibility.json)",
        );
        case ApiCompatibility.error:
        _notificationBus.showWarning(
          "Could not check Mycel compatibility with current Mycelium version.",
        );
        default:
        break;
      }
    }
  }

  void _onCollectionChanged() async {
    _nodeRepository.clearCache();
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
