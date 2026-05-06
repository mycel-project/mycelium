import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mycelium/core/either.dart';
import 'package:mycelium/core/notifications/notification.dart';
import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/navigation_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/core/stores/review_state.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/models/node_type.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/data/services/api_service.dart';
import 'package:mycelium/domain/api_status.dart';
import 'package:mycelium/domain/check_api_usecase.dart';
import 'package:mycelium/domain/navigation_usecase.dart';
import 'package:mycelium/domain/node_usecase.dart';
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
  ) {
    reviewStore.addListener(_onReviewChanged);
    nodeStore.addListener(_onNodeStoreChange);
    apiStore.addListener(handleRetry);
    reviewStore.addListener(_onReviewChange);
  }

  @override
  void dispose() {
    reviewStore.removeListener(_onReviewChanged);
    nodeStore.removeListener(_onNodeStoreChange);
    apiStore.removeListener(handleRetry);
    reviewStore.removeListener(_onReviewChange);

    _retryTimer?.cancel();

    super.dispose();
  }
  void _onNodeStoreChange() {
    dismissNoMoreReviews();
    _checkHasParent();
  }

  void _onReviewChange() {
    notifyListeners();
  }

  Timer? _retryTimer;

  void handleRetry() {
    if (apiStore.status == ApiStatus.unreachable) {
      _startRetrying();
    } else {
      _stopRetrying();
    }
  }

  void _startRetrying() {
    _retryTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      checkApiUseCase.execute();
    });
  }

  void _stopRetrying() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  void refreshNodes() {
    notifyListeners();
  }

  void _onReviewChanged() {
    if (reviewStore.state is NoMoreReviews) {
      noMoreReviewsFlag = true;
      notifyListeners();
    }
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

  Future<void> updateNodeTitle(int nodeId, String title) async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return;
    await nodeUseCase.updateNodeTitle(colId, nodeId, title);
    notifyListeners();
  }

  void nextNode() async {
    final id = await navigationUseCase.forward();
    if (id != null) _loadNode(id);
  }

  void navigateTo(int nodeId) async {
    navigationUseCase.navigateTo(nodeId);
  }

  void _checkHasParent() {
    final newValue = nodeStore.currentNode?.parentId != null;

    if (hasParent == newValue) return;

    hasParent = newValue;
    notifyListeners();
  }

  // Not reloading the cache on each open — could this be a problem?
  List<Node> getNodes() => nodeRepository.nodeCache.values.toList();
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

  Future<void> fetchRessourceFromUrl(String? url) async {
    if (url == null) return;
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return;
    final result = await nodeRepository.fetchRessourceFromUrl(colId, url);
    result.fold((error) {}, (node) async {
      await navigationUseCase.navigateTo(node.id);
      notifyListeners();
    });
  }
}
