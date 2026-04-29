import 'package:flutter/material.dart';
import 'package:mycelium/core/either.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/core/stores/review_state.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/models/node_type.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/data/services/api_service.dart';
import 'package:mycelium/domain/node_usecase.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiService apiService;
  final ReviewStore reviewStore;
  final NodeUseCase nodeUseCase;
  final NodeStore nodeStore;
  final NodeRepository nodeRepository;
  final CollectionStore collectionStore;

  bool noMoreReviewsFlag = false;

  HomeViewModel({
    required this.apiService,
    required this.reviewStore,
    required this.nodeUseCase,
    required this.nodeStore,
    required this.nodeRepository,
    required this.collectionStore,
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

  bool hasParent = false;

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

  Future<void> selectNode(int id) async {
    final colId = collectionStore.currentCollection?.id;
    final result = await nodeRepository.getNode(colId!, id);
    result.fold((err) => null, (node) => nodeStore.selectNode(node));
  }

  void dismissNoMoreReviews() {
    noMoreReviewsFlag = false;
    notifyListeners();
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
}
