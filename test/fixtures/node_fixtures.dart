import 'package:mycelium/data/models/node.dart';

Node buildTestNode({
  String id = "test_node_id",
  String collectionId = "test_col_id",
  String templateId = "test_template_id",
  String type = "fragment",
  String status = "active",
  int updatedAt = 0,
  int createdAt = 0,
  String contentPreview = "Preview",
  List<LearningUnit> learningUnits = const [],
  Map<String, dynamic> data = const {},
  String? parentId,
  int? deletedAt,
  Map<String, String>? fields,
}) {
  return Node(
    id: id,
    collectionId: collectionId,
    templateId: templateId,
    type: type,
    status: status,
    updatedAt: updatedAt,
    createdAt: createdAt,
    contentPreview: contentPreview,
    learningUnits: learningUnits,
    data: data,
    parentId: parentId,
    deletedAt: deletedAt,
    fields: fields ?? {"front": "Default test content"},
  );
}
