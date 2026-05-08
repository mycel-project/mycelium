class UserConfUpdate {
  final int? undoReviewMaxAge;
  final int? pingFrequency;

  const UserConfUpdate({this.undoReviewMaxAge, this.pingFrequency});

  Map<String, dynamic> toJson() => {
    if (undoReviewMaxAge != null) 'undo_review_max_age': undoReviewMaxAge,
    if (pingFrequency != null) 'ping_frequency': pingFrequency,
  };
}
