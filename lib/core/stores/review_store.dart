import 'package:flutter/material.dart';

/// Holds the identifier of the node currently in review mode.
class ReviewStore extends ChangeNotifier {
  
  int? _currentReviewNodeId;

  int? get currentReviewNodeId => _currentReviewNodeId;

  void startReview(int nodeId) {
    _currentReviewNodeId = nodeId;
    notifyListeners();
  }

  void stopReview() {
    _currentReviewNodeId = null;
    notifyListeners();
  }

  bool isReviewing(int nodeId) {
    return _currentReviewNodeId == nodeId;
  }
}
