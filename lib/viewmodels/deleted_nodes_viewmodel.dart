import 'package:flutter/material.dart';
import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/user_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/repositories/node_repository.dart';

class DeletedNodesViewmodel extends ChangeNotifier {
  final NodeRepository nodeRepository;
  final CollectionStore collectionStore;
  final NotificationBus notificationBus;
  final UserStore userStore;

  List<Node> deletedNodes = [];

  DeletedNodesViewmodel(
    this.nodeRepository,
    this.collectionStore,
    this.notificationBus,
    this.userStore,
  );

  String getNodeTypeName(int typeKey) {
    return nodeRepository.nodeTypesCache[typeKey]?.label ?? "Type $typeKey";
  }

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

  Future<void> restoreNode(
    int nodeId, {
    bool restoreAncestors = false,
    bool restoreDescendants = false,
  }) async {
    final collectionId = collectionStore.currentCollection?.id;
    if (collectionId == null) return;
    final result = await nodeRepository.restoreNode(
      collectionId,
      nodeId,
      restoreAncestors,
      restoreDescendants,
    );
    switch (result) {
      case ApiSuccess():
        await getDeletedNodes();
        notifyListeners();
      case ApiError error:
        notificationBus.showError("Cannot restore nodes", error);
    }
  }

  String? formatDeletedAt(Node node) {
    if (node.deletedAt == null) return null;
    final maxAgeDays = userStore.conf?.get("delete_max_age") as int? ?? 30;
    final dt = DateTime.fromMillisecondsSinceEpoch(node.deletedAt!);
    final expiresAt = dt.add(Duration(days: maxAgeDays));
    final daysLeft = expiresAt.difference(DateTime.now()).inDays;
    final daysLeftStr = daysLeft < 0 ? "Expired" : "$daysLeft days left";
    final dateStr =
    "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
    "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    return "$daysLeftStr | $dateStr";
  }
}
