import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/utils/time_utils.dart';

class RescheduleNodeUseCase {
  /// Not using NodeStore here because we may want to reschedule a node without adding it to NodeStore
  final NodeRepository nodeRepository;
  final NotificationBus notificationBus;
  final ReviewStore reviewStore;

  RescheduleNodeUseCase(
    this.nodeRepository,
    this.notificationBus,
    this.reviewStore,
  );

  Future<Node?> execute(String colId, String nodeId, String dateIso) async {
    final result = await nodeRepository.rescheduleNode(
      colId,
      nodeId,
      dateIso,
      tzOffsetMinutes,
    );
    switch (result) {
      case ApiSuccess(:final data):
        Node node = data;
        if (node.id == reviewStore.currentNodeId) {
          // (edge case) Not checking whether the node was rescheduled to the same day to keep it simple, it will simply resurface in the next queue fetch.
          reviewStore.stopReview();
        }
        return data;
      case DomainError error:
        notificationBus.showError("Cannot reschedule node", error);
    }
    return null;
  }
}
