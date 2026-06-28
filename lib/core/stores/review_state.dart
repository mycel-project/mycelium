sealed class ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewNotStarted extends ReviewState {}

class Reviewing extends ReviewState {
  final String nodeId;
  final int slot;
  Reviewing(this.nodeId, {this.slot = 1});
}

class NoMoreReviews extends ReviewState {}
