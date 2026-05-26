import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/repositories/node_repository.dart';

class UpdatePriorityUseCase {
  final NodeRepository nodeRepository;
  final NotificationBus notificationBus;
  final NodeStore nodeStore;

  UpdatePriorityUseCase(
    this.nodeRepository,
    this.notificationBus,
    this.nodeStore,
  );

  Future<Node?> execute(int colId, int nodeId, double priority) async {
    final result = await nodeRepository.reprioritiseNode(
      colId,
      nodeId,
      priority,
    );
    switch (result) {
      case ApiSuccess(:final data):
        return data;
      case ApiError error:
        notificationBus.showError("Cannot update priority", error);
        return null;
    }
  }
}
