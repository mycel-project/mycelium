import "package:flutter/material.dart";
import "package:flutter/foundation.dart";
import "package:mycelium/core/stores/node_store.dart";
import "package:mycelium/data/models/node.dart";
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';


/// ClaudeAI used to handle tree building and layouting, is a bit hacky, especially for guide line when expanding element
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
    _tree = buildTree(widget.nodes, selectedNode: selectedNode, isSpore: widget.isSpore);
  }

  @override
  void didUpdateWidget(covariant NodeTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.nodes, widget.nodes)) {
      setState(() {
          _tree = buildTree(widget.nodes, selectedNode: selectedNode, isSpore: widget.isSpore);
      });
    }
  }

  int _getDepth(TreeSliverNode node) {
    int depth = 0;
    final typedNode = node.content as Node;
    int? parentId = typedNode.parentId;
    while (parentId != null) {
      depth++;
      final parent = widget.nodes.firstWhereOrNull((n) => n.id == parentId);
      parentId = parent?.parentId;
    }
    return depth;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
            final isSelected = selectedNode?.id == typedNode.id;
            final hasChildren = node.children.isNotEmpty;
            final isSporeNode = widget.isSpore?.call(typedNode) ?? false;
            final depth = _getDepth(node);

            return Transform.translate(     
              offset: Offset(-(depth * 10.0), 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...List.generate(depth, (i) => SizedBox(
                      width: 30,
                      child: Center(
                        child: Container(
                          width: 1,
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
                        ),
                      ),
                  )),
                  SizedBox(
                    width: 30,
                    child: hasChildren
                    ? InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => setState(() => controller.toggleNode(node)),
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
                    :
                    isSporeNode
                    ?
                    const SizedBox()
                    :
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      child: Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Colors.grey.withValues(alpha: 0.5),
                      ),
                    )
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
                              color: 
                              isSelected
                              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                              : isSporeNode ?
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0)
                              :
                              Colors.transparent,
                            ),
                            child: Text(
                              formatNodeTitle(typedNode.content?['0']),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: typedNode.typeData?["dismiss"] == true 
                                ?
                                Colors.grey.withValues(alpha: 0.5)
                                :
                                Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

String formatNodeTitle(String? raw) {
  if (raw == null) return '';
  return raw.replaceAll(RegExp(r'^>+\s*', multiLine: true), '').trim();
}

List<TreeSliverNode<Node>> buildTree(
  List<Node> nodes, {
  Node? selectedNode,
  bool Function(Node node)? isSpore,
}) {
  final Map<int?, List<Node>> grouped = {};
  for (final node in nodes) {
    grouped.putIfAbsent(node.parentId, () => []).add(node);
  }

  if (isSpore != null) {
    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) {
        final aIsSpore = isSpore(a) ? 1 : 0;
        final bIsSpore = isSpore(b) ? 1 : 0;
        return aIsSpore.compareTo(bIsSpore);
      });
    }
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
    final shouldExpand =
        ancestorIds.contains(node.id) || node.id == selectedNode?.id;
    return TreeSliverNode<Node>(
      node,
      expanded: shouldExpand,
      children: children.map(build).toList(),
    );
  }

  final roots = grouped[null] ?? [];
  return roots.map(build).toList();
}
