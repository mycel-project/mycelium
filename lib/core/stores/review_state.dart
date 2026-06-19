sealed class ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewNotStarted extends ReviewState {}

class Reviewing extends ReviewState {
  final String nodeId;
  Reviewing(this.nodeId);
}

class NoMoreReviews extends ReviewState {}
