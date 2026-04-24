class NodeType {
  const NodeType({required this.label, required this.key});
  final String label;
  final int key;

  factory NodeType.fromJson(Map<String, dynamic> json) {
    return NodeType(
      label: json['label'],
      key: json['value'],
    );
  }
}
