import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mycelium/core/either.dart';
import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/navigation_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/core/stores/review_state.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/day_review_overview.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/models/node_type.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/data/services/api_service.dart';
import 'package:mycelium/domain/check_api_usecase.dart';
import 'package:mycelium/domain/get_calendar_usecase.dart';
import 'package:mycelium/domain/navigation_usecase.dart';
import 'package:mycelium/domain/node_usecase.dart';
import 'package:mycelium/domain/reschedule_node_usecase.dart';
import 'package:mycelium/domain/review_usecase.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiService apiService;
  final ReviewStore reviewStore;
  final NodeUseCase nodeUseCase;
  final NodeStore nodeStore;
  final NodeRepository nodeRepository;
  final CollectionStore collectionStore;
  final NavigationUseCase navigationUseCase;
  final NavigationStore navigationStore;
  final ReviewUseCase reviewUseCase;
  final ApiStore apiStore;
  final CheckApiUseCase checkApiUseCase;
  final NotificationBus notificationBus;
  final GetCalendarUseCase getCalendarUseCase;
  final RescheduleNodeUseCase rescheduleNodeUseCase;

  bool noMoreReviewsFlag = false;

  HomeViewModel(
    this.apiService,
    this.reviewStore,
    this.nodeUseCase,
    this.nodeStore,
    this.nodeRepository,
    this.collectionStore,
    this.navigationStore,
    this.navigationUseCase,
    this.reviewUseCase,
    this.apiStore,
    this.checkApiUseCase,
    this.notificationBus,
    this.getCalendarUseCase,
    this.rescheduleNodeUseCase,
  ) {
    reviewStore.addListener(_onReviewChanged);
    nodeStore.addListener(_onNodeStoreChange);
  }

  @override
  void dispose() {
    reviewStore.removeListener(_onReviewChanged);
    nodeStore.removeListener(_onNodeStoreChange);

    super.dispose();
  }

  void _onNodeStoreChange() {
    dismissNoMoreReviews();
    _checkHasParent();
    refreshCurrentNode(); // Mainly used to avoid the priority drift due to other nodes changes, but we refetch the whole node while we're at it.
  }

  void refreshNodes() {
    notifyListeners();
  }

  void _onReviewChanged() {
    if (reviewStore.state is NoMoreReviews) {
      noMoreReviewsFlag = true;
    }
    notifyListeners();
  }

  bool isCurrentNodeUnderReview() {
    return nodeStore.currentNode?.id == reviewStore.currentNodeId &&
        reviewStore.currentNodeId != null;
  }

  bool hasParent = false;

  void openHistory() {
    print("History not implemented yet");
  }

  bool hasPreviousNodes() => navigationUseCase.canGoBack;

  bool hasNextNodes() => navigationUseCase.canGoForward;

  void previousNode() async {
    final id = await navigationUseCase.back();
    if (id != null) _loadNode(id);
  }

  Future<String?> getNodeTitle(int nodeId) async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return "";
    return await nodeUseCase.getNodeTitle(colId, nodeId);
  }

  Future<bool> updateNodeTitle(int nodeId, String title) async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return false;
    final result = await nodeUseCase.updateNodeTitle(colId, nodeId, title);
    if (result is Node) {
      nodeStore.selectNode(result);
      notifyListeners();
      return true;
    }
    return false;
  }

  void nextNode() async {
    final id = await navigationUseCase.forward();
    if (id != null) _loadNode(id);
  }

  void navigateTo(int nodeId) async {
    navigationUseCase.navigateTo(nodeId);
  }

  void _checkHasParent() {
    final parentId = nodeStore.currentNode?.parentId;
    final exists =
        parentId != null && nodeRepository.nodeCache.containsKey(parentId);

    if (hasParent == exists) return;

    hasParent = exists;
    notifyListeners();
  }

  // Not reloading the cache on each open — could this be a problem?
  List<Node> getNodes() => nodeRepository.nodeCache.values.toList();
  int get nodeCount => nodeRepository.nodeCache.length;

  // Should this method live in a node store monitor/observer?
  Future<bool> refreshCurrentNode() async {
    final colId = collectionStore.currentCollection?.id;
    Node? node = nodeStore.currentNode;
    if (colId == null || node == null) return false;
    final result = await nodeRepository.loadNode(colId, node.id);
    switch (result) {
      case ApiSuccess():
        notifyListeners();
        return true;
      case ApiError error:
        notificationBus.showError("Cannot refresh node", error);
        return false;
    }
  }

  Future<bool> refreshPriorities() async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return false;
    final result = await nodeRepository.getPriorities(colId);
    switch (result) {
      case ApiSuccess():
        notifyListeners();
        return true;
      case ApiError error:
        notificationBus.showError("Cannot refresh priorities", error);
        return false;
    }
  }

  List<NodeType> getNodeTypes() =>
      nodeRepository.nodeTypesCache.values.toList();

  // Navigate without pushing in history
  Future<void> _loadNode(int id) async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return;
    final result = await nodeRepository.getNode(colId, id);
    result.fold((err) => null, (node) => nodeStore.selectNode(node));
  }

  void dismissNoMoreReviews() {
    if (!noMoreReviewsFlag) return;

    noMoreReviewsFlag = false;
    notifyListeners();
  }

  Future<void> deleteNode(int nodeId) async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return;
    await nodeUseCase.deleteNode(colId, nodeId);
    notifyListeners();
  }

  void upPress() {
    nodeUseCase.selectParentNode();
  }

  void longUpPress() {
    nodeUseCase.selectRootNode();
  }

  Future<void> handleNextReview() async {
    final result = await reviewUseCase.handleNextReview();
    if (result case ApiError error) {
      final msg = error.code == "no_collection"
          ? "No collection selected"
          : "Cannot load next review";
      notificationBus.showError(msg, error);
    }
  }

  String? currentCollectionName() {
    return collectionStore.currentCollection?.name;
  }

  Future<bool> updatePriority(int nodeId, int priority) async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return false;
    final result = await nodeRepository.reprioritiseNode(
      colId,
      nodeId,
      priority,
    );
    switch (result) {
      case ApiSuccess(:final data):
        final node = data;
        nodeStore.selectNode(node);
        notifyListeners();
        return true;
      case ApiError error:
        notificationBus.showError("Cannot update priority", error);
        return false;
    }
  }

  Future<bool> rescheduleNode(int nodeId, String dateIso) async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return false;
    final result = await rescheduleNodeUseCase.execute(colId, nodeId, dateIso);
    if (result is Node) {
      nodeStore.selectNode(result);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> fetchRessourceFromUrl(String? url) async {
    if (url == null || url.isEmpty) {
      notificationBus.showWarning("Empty URL");
      return false;
    }
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return false;
    final result = await nodeRepository.fetchRessourceFromUrl(colId, url);
    switch (result) {
      case ApiSuccess(:final data):
        final node = data;
        await navigationUseCase.navigateTo(node.id);
        notifyListeners();
        return true;
      case ApiError error:
        notificationBus.showError("Cannot import ressource", error);
        return false;
    }
  }

  Map<DateTime, ({int spores, int fragments})> repsData = {
    DateTime(2026, 5, 12): (spores: 300, fragments: 9),
    DateTime(2026, 5, 18): (spores: 1, fragments: 0),
    DateTime(2026, 5, 13): (spores: 1, fragments: 6),
  };

  Map<DateTime, DayReviewOverview> calendar = {};

  Future<void> getCalendar() async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return;
    final newCalendar = await getCalendarUseCase.execute(colId);
    if (newCalendar == null) {
      calendar = {};
    } else {
      calendar = newCalendar;
      notifyListeners();
    }
  }
}
