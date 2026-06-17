import 'package:flutter/painting.dart';
import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/core/stores/user_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/domain/navigation_usecase.dart';
import 'package:mycelium/utils/time_utils.dart';

class CreateExtractUseCase {
  final NodeRepository nodeRepository;
  final NotificationBus notificationBus;
  final NodeStore nodeStore;
  final UserStore userStore;
  final NavigationUseCase navigationUseCase;

  CreateExtractUseCase(
    this.nodeRepository,
    this.notificationBus,
    this.nodeStore,
    this.userStore,
    this.navigationUseCase,
  );

  Future<Node?> execute(
    Node node,
    String extractType,
    String content,
    TextSelection selection, {
    VoidCallback? onMismatch,
  }) async {
    /// Return created extract if extract has been created

    bool? addNav = userStore.conf?.get("add_extract_to_nav");

    final result = await nodeRepository.createExtract(
      node.collectionId,
      node.id,
      content.substring(selection.start, selection.end),
      "0",
      selection.start,
      selection.end,
      extractType,
      tzOffsetMinutes,
    );

    switch (result) {
      case ApiSuccess(:final data):
        final updatedNode = data.firstWhere((n) => n.id == node.id);
        final extract = data.firstWhere((n) => n.id != node.id);

        nodeStore.selectNode(updatedNode);

        if (addNav == true) {
          navigationUseCase.pushToHistory(extract.id, offset: 0);
        }
        return extract;
      case DomainError error:
        if (error.code == "EXTRACT_MISMATCH") {
          notificationBus.showError("Retry - report if this persists", error);
          onMismatch?.call();
          return null;
        }
        notificationBus.showError("Can't create extract", error);
    }
    return null;
  }
}
