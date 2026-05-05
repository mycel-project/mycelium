class Collection {
  const Collection({required this.id, required this.name});
  final int id;
  final String name;

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'],
      name: json['name'],
    );
  }

  Collection copyWith({int? id, String? name}) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
