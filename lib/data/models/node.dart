class Node {
  const Node({required this.id, required this.type, required this.collectionId, this.parentId, this.content});
  final int id;
  final int type;
  final int collectionId;
  final int? parentId;
  final Map? content;

  factory Node.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'];
    
    return Node(
      id: json['id'],
      type: json['type'],
      parentId: json["parent_id"],
      collectionId: json["collection_id"],
      content: rawContent is Map<String, dynamic>
          ? rawContent['fields'] as Map<String, dynamic>?
          : null,
    );
  }
}
