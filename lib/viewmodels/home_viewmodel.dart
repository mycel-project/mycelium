import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/core/stores/review_state.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/data/services/api_service.dart';
import 'package:mycelium/domain/node_usecase.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiService apiService;
  final ReviewStore reviewStore;
  final NodeUseCase nodeUseCase;
  final NodeStore nodeStore;

  bool noMoreReviewsFlag = false;

  HomeViewModel({
    required this.apiService,
    required this.reviewStore,
    required this.nodeUseCase,
    required this.nodeStore,
  }) {
    reviewStore.addListener(_onReviewChanged);
    nodeStore.addListener(_checkHasParent);
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
