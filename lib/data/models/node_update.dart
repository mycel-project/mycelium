class NodeUpdate {
  const NodeUpdate({
    this.parentId,
    this.templateId,
    this.type,
    this.status,
    this.fields,
    this.data,
  });

  final String? parentId;
  final String? templateId;
  final String? type;
  final String? status;
  final Map<String, String>? fields;
  final Map<String, dynamic>? data;

  Map<String, dynamic> toJson() => {
    if (parentId != null) 'parent_id': parentId,
    if (templateId != null) 'template_id': templateId,
    if (type != null) 'type': type,
    if (status != null) 'status': status,
    if (fields != null) 'fields': fields,
    if (data != null) 'data': data,
  };
}
