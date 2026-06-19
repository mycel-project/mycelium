import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/outline_entry.dart';
import 'package:mycelium/data/repositories/node_repository.dart';

class GetOutlineUseCase {
  final NodeRepository nodeRepository;
  final NotificationBus notificationBus;

  GetOutlineUseCase(this.nodeRepository, this.notificationBus);

  Future<List<OutlineEntry>?> execute(
    String colId,
    String nodeId, {
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) nodeRepository.clearOutlineCache();
    final result = await nodeRepository.getOutline(colId, nodeId);
    switch (result) {
      case ApiSuccess(:final data):
        return data;
      case DomainError error:
        notificationBus.showError("Cannot get outline", error);
        return null;
    }
    return null;
  }
}
