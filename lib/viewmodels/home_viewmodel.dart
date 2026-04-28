import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/review_state.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/data/services/api_service.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiService apiService;
  final ReviewStore reviewStore;

  bool noMoreReviewsFlag = false;

  HomeViewModel({required this.apiService, required this.reviewStore}) {
    reviewStore.addListener(_onReviewChanged);
  }

  void _onReviewChanged() {
    if (reviewStore.state is NoMoreReviews) {
      noMoreReviewsFlag = true;
      notifyListeners();
    }
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
}
