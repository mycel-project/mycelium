import 'package:mycelium/data/models/node_data.dart';

class Node {
  const Node({
    required this.id,
    required this.type,
    required this.collectionId,
    required this.priority,
    this.parentId,
    this.content,
    this.typeData,
    this.data,
    this.deletedAt,
  });
  final int id;
  final int type;
  final int collectionId;
  final int priority;
  final int? parentId;
  final Map? content;
  final Map? typeData;
  final NodeData? data;
  final int? deletedAt;
  
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
      typeData: json['type_data'],
      data: json['data'] != null ? NodeData.fromJson(json['data']) : null,
      deletedAt: json['deleted_at'],
      priority: json['priority'],
    );
  }
}
