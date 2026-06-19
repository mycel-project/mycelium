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
import 'package:mycelium/core/stores/scroll_position_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/day_review_overview.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/models/outline_entry.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/data/network/api_client.dart';
import 'package:mycelium/domain/check_api_usecase.dart';
import 'package:mycelium/domain/cloze_mode.dart';
import 'package:mycelium/domain/get_calendar_usecase.dart';
import 'package:mycelium/domain/get_outline_usecase.dart';
import 'package:mycelium/domain/navigation_usecase.dart';
import 'package:mycelium/domain/node_usecase.dart';
import 'package:mycelium/domain/refresh_priorities_usecase.dart';
import 'package:mycelium/domain/reschedule_node_usecase.dart';
import 'package:mycelium/domain/review_usecase.dart';
import 'package:mycelium/domain/update_priority_usecase.dart';
import 'package:mycelium/utils/time_utils.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiClient apiService;
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
  final UpdatePriorityUseCase updatePriorityUseCase;
  final RefreshPrioritiesUseCase refreshPrioritiesUseCase;
  final GetOutlineUseCase getOutlineUseCase;
  final ScrollPositionStore scrollPositionStore;

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
    this.updatePriorityUseCase,
    this.refreshPrioritiesUseCase,
    this.getOutlineUseCase,
    this.scrollPositionStore,
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
    closeLeftPanelIfReviewingSpore();
    refreshCurrentNode(); // Mainly used to avoid the priority drift due to other nodes changes, but we refetch the whole node while we're at it.
  }

  void refreshNodes() {
    notifyListeners();
  }

  void closeLeftPanelIfReviewingSpore() {
    if (reviewStore.currentNodeId != null &&
        nodeStore.currentNode?.id == reviewStore.currentNodeId &&
        nodeStore.currentNode?.type == "spore") {
      closeLeftPanel();
    }
  }

  void _onReviewChanged() {
    if (reviewStore.state is NoMoreReviews) {
      noMoreReviewsFlag = true;
    }
    closeLeftPanelIfReviewingSpore();
    notifyListeners();
  }

  bool isCurrentNodeUnderReview() {
    return nodeStore.currentNode?.id == reviewStore.currentNodeId &&
        reviewStore.currentNodeId != null;
  }

  bool hasParent = false;

  void openHistory() {
    // History not implemented yet
  }

  bool hasPreviousNodes() => navigationUseCase.canGoBack;

  bool hasNextNodes() => navigationUseCase.canGoForward;

  void previousNode() async {
    final id = await navigationUseCase.back();
    if (id != null) _loadNode(id);
  }

  Future<String?> getNodeTitle(String nodeId) async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return "";
    return await nodeUseCase.getNodeTitle(colId, nodeId);
  }

  Future<bool> updateNodeTitle(String nodeId, String title) async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return false;
    final result = await nodeUseCase.updateNodeTitle(colId, nodeId, title);
    if (result is Node) {
      notifyListeners();
      return true;
    }
    return false;
  }

  void nextNode() async {
    final id = await navigationUseCase.forward();
    if (id != null) _loadNode(id);
  }

  void navigateTo(String nodeId) async {
    if (nodeId != nodeStore.currentNode?.id) {
      navigationUseCase.navigateTo(nodeId);
    }
  }

  Future<void> undoReview() async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return;
    await reviewUseCase.undo(colId);
  }

  void _checkHasParent() {
    final parentId = nodeStore.currentNode?.parentId;
    final exists =
        parentId != null && nodeRepository.nodeCache.containsKey(parentId);

    if (hasParent == exists) return;

    hasParent = exists;
    notifyListeners();
  }

  bool get hasNode => nodeStore.currentNode != null;

  int get scrollPosition => scrollPositionStore.offset;

  Future<List<OutlineEntry>?> getCurrentOutline({
    bool forceRefresh = false,
  }) async {
    Node? node = nodeStore.currentNode;
    final colId = collectionStore.currentCollection?.id;
    if (colId == null || node == null) return null;
    return await getOutlineUseCase.execute(
      colId,
      node.id,
      forceRefresh: forceRefresh,
    );
  }

  void scrollToOffset(int offset) {
    scrollPositionStore.update(offset);
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
      case DomainError error:
        notificationBus.showError("Cannot refresh node", error);
    }
    return false;
  }

  Future<bool> refreshPriorities() async {
    final result = await refreshPrioritiesUseCase.execute();
    if (result) notifyListeners();
    return result;
  }

  // Navigate without pushing in history
  Future<void> _loadNode(String id) async {
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

  bool _isEndPanelOpen = false;
  bool get isEndPanelOpen => _isEndPanelOpen;

  void toggleEndPanel() {
    _isEndPanelOpen = !_isEndPanelOpen;
    notifyListeners();
  }

  bool _isLeftPanelOpen = false;
  bool get isLeftPanelOpen => _isLeftPanelOpen;

  void toggleLeftPanel() {
    _isLeftPanelOpen = !_isLeftPanelOpen;
    notifyListeners();
  }

  void closeLeftPanel() {
    if (_isLeftPanelOpen == true) {
      _isLeftPanelOpen = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  Future<void> deleteNode(String nodeId) async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return;
    await nodeUseCase.deleteNode(colId, nodeId);
    notifyListeners();
  }

  void upPress() {
    nodeUseCase.selectParentNode();
  }

  void goRootNode() {
    nodeUseCase.selectRootNode();
  }

  Future<void> handleNextReview() async {
    final result = await reviewUseCase.handleNextReview();
    if (result case DomainError error) {
      notificationBus.showError("Cannot get review", error);
    }
  }

  String? currentCollectionName() {
    return collectionStore.currentCollection?.name;
  }

  Future<bool> updatePriority(String nodeId, double priority) async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return false;
    final result = await updatePriorityUseCase.execute(colId, nodeId, priority);
    if (result is Node) {
      nodeStore.selectNode(result);
      await refreshPriorities();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> rescheduleNode(String nodeId, String dateIso) async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return false;
    final result = await rescheduleNodeUseCase.execute(colId, nodeId, dateIso);
    if (result is Node) {
      nodeStore.selectNode(result);
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
    final result = await nodeRepository.fetchRessourceFromUrl(
      colId,
      url,
      tzOffsetMinutes,
    ); // require dedicated UseCase
    switch (result) {
      case ApiSuccess(:final data):
        final node = data;
        await navigationUseCase.navigateTo(node.id);
        notifyListeners();
        return true;
      case DomainError error:
        notificationBus.showError("Cannot import ressource", error);
    }
    return false;
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

  String hideSpore(String content) {
    return reviewUseCase.transformClozeContent(content, mode: ClozeMode.hide);
  }
}
