import 'package:flutter/material.dart';
import 'package:mycelium/core/either.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/navigation_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/core/stores/review_state.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/models/node_type.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/data/services/api_service.dart';
import 'package:mycelium/domain/navigation_usecase.dart';
import 'package:mycelium/domain/node_usecase.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiService apiService;
  final ReviewStore reviewStore;
  final NodeUseCase nodeUseCase;
  final NodeStore nodeStore;
  final NodeRepository nodeRepository;
  final CollectionStore collectionStore;
  final NavigationUseCase navigationUseCase;
  final NavigationStore navigationStore;

  bool noMoreReviewsFlag = false;

  HomeViewModel({
    required this.apiService,
    required this.reviewStore,
    required this.nodeUseCase,
    required this.nodeStore,
    required this.nodeRepository,
    required this.collectionStore,
    required this.navigationStore,
    required this.navigationUseCase,
  }) {
    reviewStore.addListener(_onReviewChanged);
    nodeStore.addListener(_checkHasParent);
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
    return nodeStore.currentNode?.id == reviewStore.currentNodeId;
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
    if (nodeStore.currentNode?.parentId != null) {
      hasParent = true;
    } else {
      hasParent = false;
    }
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
    noMoreReviewsFlag = false;
    notifyListeners();
  }

  Future<void> deleteNode(int nodeId) async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) return;
    final result = await nodeRepository.deleteNode(colId, nodeId);
    result.fold((err) {}, (deletedIds) {
      if (deletedIds.contains(nodeStore.currentNode?.id)) {
        nodeStore.selectNode(null);
      }
      navigationUseCase.onNodesDeleted(deletedIds);
      notifyListeners();
    });
  }

  bool isCheckingConnection = false;
  Future<void> connectionStatusClick() async {
    // only ui state
    isCheckingConnection = true;
    notifyListeners();

    await Future.wait([
      apiService.checkReachability(),
      Future.delayed(const Duration(milliseconds: 500)),
    ]);

    isCheckingConnection = false;
    notifyListeners();
  }

  void upPress() {
    nodeUseCase.selectParentNode();
  }

  void longUpPress() {
    nodeUseCase.selectRootNode();
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
