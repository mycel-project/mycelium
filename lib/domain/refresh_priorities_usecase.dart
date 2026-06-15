import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/repositories/node_repository.dart';

class RefreshPrioritiesUseCase {
  final NodeRepository nodeRepository;
  final CollectionStore collectionStore;
  final NotificationBus notificationBus;

  RefreshPrioritiesUseCase(this.nodeRepository, this.collectionStore, this.notificationBus);

  Future<bool> execute() async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return false;
    final result = await nodeRepository.getPriorities(colId);
    switch (result) {
      case ApiSuccess():
        return true;
      case DomainError error:
        notificationBus.showError("Cannot refresh priorities", error);
    }
    return false;
  }
}
