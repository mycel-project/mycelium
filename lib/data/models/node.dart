import 'package:mycelium/data/models/node_data.dart';

class Node {
  const Node({
    required this.id,
    required this.type,
    required this.collectionId,
    required this.priority,
    this.due,
    this.parentId,
    this.content,
    this.typeData,
    this.data,
    this.deletedAt,
  });
  final String id;
  final int type;
  final String collectionId;
  final double priority;
  final String? parentId;
  final Map? content;
  final Map? typeData;
  final NodeData? data;
  final int? deletedAt;
  final int? due;

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
      due: json['due'],
      deletedAt: json['deleted_at'],
      priority: double.parse(json['priority'].toStringAsFixed(3)),
    );
  }

  Node copyWith({
    String? id,
    int? type,
    String? collectionId,
    double? priority,
    String? parentId,
    int? due,
    Map? content,
    Map? typeData,
    NodeData? data,
    int? deletedAt,
  }) {
    return Node(
      id: id ?? this.id,
      type: type ?? this.type,
      collectionId: collectionId ?? this.collectionId,
      priority: priority ?? this.priority,
      parentId: parentId ?? this.parentId,
      content: content ?? this.content,
      typeData: typeData ?? this.typeData,
      data: data ?? this.data,
      deletedAt: deletedAt ?? this.deletedAt,
      due: due ?? this.due,
    );
  }
}
