import "package:flutter/material.dart";
import "package:flutter/foundation.dart";
import "package:mycelium/core/stores/node_store.dart";
import "package:mycelium/data/models/node.dart";
import 'package:provider/provider.dart';

class NodeTree extends StatefulWidget {
  final List<Node> nodes;

  final void Function(int id)? clickCallback;

  const NodeTree({
    super.key,
    required this.nodes,
    this.isSpore,
    this.clickCallback,
  });

  final bool Function(Node node)? isSpore;

  @override
  State<NodeTree> createState() => _NodeTreeState();
}

class _NodeTreeState extends State<NodeTree> {
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
    final selectedNode = context.select<NodeStore, Node?>((s) => s.currentNode);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          TreeSliver(
            tree: _tree,
            controller: controller,
            treeNodeBuilder:
                (
                  BuildContext context,
                  TreeSliverNode<dynamic> node,
                  AnimationStyle animationStyle,
                ) {
                  final Node typedNode = node.content as Node;
                  final isSelected = selectedNode?.id == typedNode.id;
                  final hasChildren = node.children.isNotEmpty;
                  final isSporeNode = widget.isSpore?.call(typedNode) ?? false;

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
                                child: Center(
                                  child: AnimatedRotation(
                                    turns: node.isExpanded ? 0.25 : 0,
                                    duration: const Duration(milliseconds: 200),
                                    child: const Icon(
                                      Icons.chevron_right,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            widget.clickCallback?.call(typedNode.id);
                            Navigator.pop(context);
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primary.withValues(alpha: 0.2)
                                  : Colors.transparent,
                              border: Border(
                                left: BorderSide(
                                  color: isSporeNode
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
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

    return TreeSliverNode<Node>(node, children: children.map(build).toList());
  }

  final roots = grouped[null] ?? [];

  return roots.map(build).toList();
}
