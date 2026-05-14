import 'package:flutter/painting.dart';
import 'package:mycelium/core/notifications/notification.dart';
import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/repositories/node_repository.dart';

class CreateExtractUseCase {
  final NodeRepository nodeRepository;
  final NotificationBus notificationBus;
  final NodeStore nodeStore;

  CreateExtractUseCase(
    this.nodeRepository,
    this.notificationBus,
    this.nodeStore,
  );

  Future<bool> execute(
    Node node,
    String extractType,
    String content,
    TextSelection selection,
  ) async {
    /// Return true if extract has been created
    
    final nodeType = nodeRepository.getNodeTypeByLabelSync(extractType);
    if (nodeType == null) {
      notificationBus.show(
        "Cannot extract: unknown node type: $extractType",
        NotificationType.error,
      );
      return false;
    }

    final result = await nodeRepository.createExtract(
      node.collectionId,
      node.id,
      content.substring(selection.start, selection.end),
      "0",
      selection.start,
      selection.end,
      nodeType.key,
    );

    switch (result) {
      case ApiSuccess(:final data):
        final nodes = data;
        for (final node in nodes) {
          if (node.id == node.id) {
            nodeStore.selectNode(node);
          }
        }
        return true;
      case ApiError error:
        notificationBus.showError("Can't create extract", error);
        return false;
    }
  }
}
