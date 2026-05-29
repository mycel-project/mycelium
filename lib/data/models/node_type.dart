class NodeType {
  static const fragment = NodeType(label: 'FRAGMENT', key: 1);
  static const spore = NodeType(label: 'SPORE', key: 2);
  
  const NodeType({required this.label, required this.key});
  final String label;
  final int key;

  factory NodeType.fromString(String type) {
    switch (type) {
      case 'FRAGMENT': return NodeType.fragment;
      case 'SPORE': return NodeType.spore;
      default: throw ArgumentError('Unknown node type: $type');
    }
  }
}
