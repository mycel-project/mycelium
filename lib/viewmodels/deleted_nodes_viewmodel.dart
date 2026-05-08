import 'package:flutter/material.dart';
import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/repositories/node_repository.dart';

class DeletedNodesViewmodel extends ChangeNotifier {
  final NodeRepository nodeRepository;
  final CollectionStore collectionStore;
  final NotificationBus notificationBus;

  List<Node> deletedNodes = [];

  DeletedNodesViewmodel(
    this.nodeRepository,
    this.collectionStore,
    this.notificationBus,
  );

  Future<void> getDeletedNodes() async {
    final collectionId = collectionStore.currentCollection?.id;
    if (collectionId == null) return;
    final result = await nodeRepository.loadDeletedNodes(collectionId);
    switch (result) {
      case ApiSuccess():
        deletedNodes = result.data;
        notifyListeners();
      case ApiError error:
        notificationBus.showError("Cannot get deleted nodes", error);
    }
  }
}
