import 'package:mycelium/data/models/node.dart';

class ReviewTarget {
  final Node node;
  final int slot;

  ReviewTarget({required this.node, required this.slot});

  factory ReviewTarget.fromJson(Map<String, dynamic> json) => ReviewTarget(
    node: Node.fromJson(json['node']),
    slot: json['slot'] ?? 0,
  );
}
