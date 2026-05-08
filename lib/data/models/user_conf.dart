class UserConf {
  const UserConf({
    required this.undoReviewMaxAge,
    required this.pingFrequency,
  });

  final int undoReviewMaxAge;
  final int pingFrequency;

  factory UserConf.fromJson(Map<String, dynamic> json) {
    return UserConf(
      undoReviewMaxAge: json['undo_review_max_age'],
      pingFrequency: json['ping_frequency'],
    );
  }
}
