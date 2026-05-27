class OutlineEntry {
  final int level;
  final String title;
  final int offset;

  const OutlineEntry({
    required this.level,
    required this.title,
    required this.offset,
  });

  factory OutlineEntry.fromJson(Map<String, dynamic> json) => OutlineEntry(
    level: json['level'],
    title: json['title'],
    offset: json['offset'],
  );
}
