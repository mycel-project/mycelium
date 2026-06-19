import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/repositories/node_repository.dart';

class UpdatePriorityUseCase {
  final NodeRepository nodeRepository;
  final NotificationBus notificationBus;

  UpdatePriorityUseCase(
    this.nodeRepository,
    this.notificationBus,
  );

  Future<Node?> execute(String colId, String nodeId, double priority, {int slot = 0}) async {
    final result = await nodeRepository.reprioritiseNode(
      colId,
      nodeId,
      priority,
      slot,
    );
    switch (result) {
      case ApiSuccess(:final data):
        return data;
      case DomainError error:
        notificationBus.showError("Cannot update priority", error);
    }
    return null;
  }
}
