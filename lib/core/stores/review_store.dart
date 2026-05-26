import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/review_state.dart';

/// Holds the review state (and id of the node currently in review mode).
class ReviewStore extends ChangeNotifier {
  ReviewState _state = ReviewNotStarted();

  ReviewState get state => _state;

  void setReview(int nodeId) {
    _state = Reviewing(nodeId);
    notifyListeners();
  }

  void stopReview() {
    _state = ReviewNotStarted();
    notifyListeners();
  }

  void endReview() {
    _state = NoMoreReviews();
    notifyListeners();
    _state = ReviewNotStarted();
    notifyListeners();
  }

  void setLoading() {
    _state = ReviewLoading();
    notifyListeners();
  }

  int? get currentNodeId {
    final s = _state;
    return s is Reviewing ? s.nodeId : null;
  }
}
