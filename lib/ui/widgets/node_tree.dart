import "package:flutter/material.dart";
import "package:flutter/foundation.dart";
import "package:mycelium/data/models/node.dart";

class NodeTree extends StatefulWidget {
  final List<Node> nodes;

  const NodeTree({super.key, required this.nodes});

  @override
  State<NodeTree> createState() => _NodeTreeState();
}

class _NodeTreeState extends State<NodeTree> {
  Node? _selectedNode;
  final TreeSliverController controller = TreeSliverController();

  List<TreeSliverNode<Node>> _tree = [];

  @override
  void initState() {
    super.initState();
    _tree = buildTree(widget.nodes);
  }

  @override
  void didUpdateWidget(covariant NodeTree oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listEquals(oldWidget.nodes, widget.nodes)) {
      setState(() {
        _tree = buildTree(widget.nodes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          TreeSliver(
            tree: _tree,
            controller: controller,
            treeNodeBuilder: (
              BuildContext context,
              TreeSliverNode<dynamic> node,
              AnimationStyle animationStyle,
            ) {
              final Node typedNode = node.content as Node;
              final isSelected = _selectedNode == typedNode;
              final hasChildren = node.children.isNotEmpty;

              return Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: hasChildren
                        ? InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              setState(() {
                                controller.toggleNode(node);
                              });
                            },
                            child: const Center(
                              child: Icon(Icons.chevron_right, size: 20),
                            ),
                          )
                        : const SizedBox(),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedNode = typedNode;
                        });
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.shade100
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${typedNode.content?['0']}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

List<TreeSliverNode<Node>> buildTree(List<Node> nodes) {
  final Map<int?, List<Node>> grouped = {};

  for (final node in nodes) {
    grouped.putIfAbsent(node.parentId, () => []).add(node);
  }

  TreeSliverNode<Node> build(Node node) {
    final children = grouped[node.id] ?? [];

    return TreeSliverNode<Node>(
      node,
      children: children.map(build).toList(),
    );
  }

  final roots = grouped[null] ?? [];

  return roots.map(build).toList();
}
