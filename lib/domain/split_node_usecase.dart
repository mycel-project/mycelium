import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/utils/time_utils.dart';

class SplitNodeUseCase {
  final NodeRepository nodeRepository;
  final NotificationBus notificationBus;

  SplitNodeUseCase(
    this.nodeRepository,
    this.notificationBus,
  );

  Future<List<Node>?> execute(String colId, String nodeId, int level) async {
    final result = await nodeRepository.splitNode(
      colId,
      nodeId,
      level,
      tzOffsetMinutes,
    );
    switch (result) {
      case ApiSuccess(:final data):
        return data;
      case ApiError error:
        notificationBus.showError("Cannot split node", error);
    }
    return null;
  }
}
