import "package:flutter/material.dart";
import "package:flutter/foundation.dart";
import "package:mycelium/core/stores/node_store.dart";
import "package:mycelium/data/models/node.dart";
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class NodeTree extends StatefulWidget {
  final List<Node> nodes;
  final void Function(int id)? clickCallback;
  final Future<void> Function(int id, LongPressStartDetails details)? longPressCallback;
  final bool Function(Node node)? isSpore;

  const NodeTree({
      super.key,
      required this.nodes,
      this.isSpore,
      this.clickCallback,
      this.longPressCallback,
  });

  @override
  State<NodeTree> createState() => _NodeTreeState();
}

class _NodeTreeState extends State<NodeTree> {
  final TreeSliverController controller = TreeSliverController();

  List<TreeSliverNode<Node>> _tree = [];
  Node? selectedNode;

  @override
  void initState() {
    super.initState();
    final store = context.read<NodeStore>();
    selectedNode = store.currentNode;
    _tree = buildTree(widget.nodes, selectedNode: selectedNode);
  }

  @override
  void didUpdateWidget(covariant NodeTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.nodes, widget.nodes)) {
      setState(() {
          _tree = buildTree(widget.nodes, selectedNode: selectedNode);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
                  child: GestureDetector(
                    onLongPressStart: (details) {
                      widget.longPressCallback?.call(typedNode.id, details);
                    },
                    child: Material( 
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          widget.clickCallback?.call(typedNode.id);
                          FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.pop(context);
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
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
                            "${typedNode.content?['0'].trim()}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  )
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

List<TreeSliverNode<Node>> buildTree(List<Node> nodes, {Node? selectedNode}) {
  // ClaudeAI
  final Map<int?, List<Node>> grouped = {};

  for (final node in nodes) {
    grouped.putIfAbsent(node.parentId, () => []).add(node);
  }

  final Set<int> ancestorIds = {};
  if (selectedNode != null) {
    Node? current = nodes.firstWhereOrNull((n) => n.id == selectedNode.id);
    while (current?.parentId != null) {
      ancestorIds.add(current!.parentId!);
      current = nodes.firstWhereOrNull((n) => n.id == current!.parentId);
    }
  }

  TreeSliverNode<Node> build(Node node) {
    final children = grouped[node.id] ?? [];
    final shouldExpand = ancestorIds.contains(node.id);

    return TreeSliverNode<Node>(
      node,
      expanded: shouldExpand,
      children: children.map(build).toList(),
    );
  }

  final roots = grouped[null] ?? [];
  return roots.map(build).toList();
}
