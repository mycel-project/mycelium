class NodeUpdate {
  const NodeUpdate({
    this.parentId,
    this.content,
    this.data,
    this.type,
    this.due,
    this.priority,
    this.lastReview,
    this.typeData,
  }) : assert(type == null || type >= 0, 'type must be positive');

  final String? parentId;
  final Map<String, dynamic>? content;
  final Map<String, dynamic>? data;
  final int? type;
  final int? due;
  final String? priority;
  final int? lastReview;
  final Map<String, dynamic>? typeData;

  Map<String, dynamic> toJson() => {
    if (parentId != null) 'parent_id': parentId,
    if (content != null) 'content': content,
    if (data != null) 'data': data,
    if (type != null) 'type': type,
    if (due != null) 'due': due,
    if (priority != null) 'priority': priority,
    if (lastReview != null) 'last_review': lastReview,
    if (typeData != null) 'type_data': typeData,
  };
}
