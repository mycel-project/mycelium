class DayReviewOverview {
  final String date; 
  final int dueSpores;
  final int dueFragments;
  final int reviewedSpores;
  final int reviewedFragments;

  const DayReviewOverview({
    required this.date,
    this.dueSpores = 0,
    this.dueFragments = 0,
    this.reviewedSpores = 0,
    this.reviewedFragments = 0,
  });

  factory DayReviewOverview.fromJson(Map<String, dynamic> json) {
    return DayReviewOverview(
      date: json['date'] as String,
      dueSpores: json['due_spores'] ?? 0,
      dueFragments: json['due_fragments'] ?? 0,
      reviewedSpores: json['reviewed_spores'] ?? 0,
      reviewedFragments: json['reviewed_fragments'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'due_spores': dueSpores,
      'due_fragments': dueFragments,
      'reviewed_spores': reviewedSpores,
      'reviewed_fragments': reviewedFragments,
    };
  }
}
