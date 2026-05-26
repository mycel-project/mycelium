import 'package:flutter/painting.dart';
import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/repositories/node_repository.dart';

class RemoveLinksUseCase {
  final NodeRepository nodeRepository;
  final NotificationBus notificationBus;
  final NodeStore nodeStore;

  RemoveLinksUseCase(this.nodeRepository, this.notificationBus, this.nodeStore);

  Future<bool> execute(
    Node node,
    String content,
    TextSelection? selection,
  ) async {
    int start;
    int end;
    if (selection == null) {
      start = 0;
      end = content.length;
    } else {
      start = selection.start;
      end = selection.end;
    }
    final result = await nodeRepository.removeLinks(
      node.collectionId,
      node.id,
      content.substring(start, end),
      "0",
      start,
      end,
    );

    switch (result) {
      case ApiSuccess(:final data):
        final node = data;
        nodeStore.selectNode(node);
        return true;
      case ApiError error:
        notificationBus.showError("Can't remove links", error);
        return false;
    }
  }
}
