import "package:flutter/material.dart";
import "package:flutter/foundation.dart";
import "package:mycelium/core/stores/node_store.dart";
import "package:mycelium/data/models/node.dart";
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import 'package:flutter_svg/flutter_svg.dart';

/// Based on ClaudAI to handle tree building and layouting, is a bit hacky, especially for guide line when expanding element, maybe my manual modifications make it even more hacky ?
class NodeTree extends StatefulWidget {
  final List<Node> nodes;
  final void Function(int id)? clickCallback;
  final Future<void> Function(int id, LongPressStartDetails details)?
  longPressCallback;
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
    _tree = buildTree(
      widget.nodes,
      selectedNode: selectedNode,
      isSpore: widget.isSpore,
    );
  }

  @override
  void didUpdateWidget(covariant NodeTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.nodes, widget.nodes)) {
      setState(() {
        _tree = buildTree(
          widget.nodes,
          selectedNode: selectedNode,
          isSpore: widget.isSpore,
        );
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
          toggleAnimationStyle: AnimationStyle(
            duration: Duration
                .zero, // Disable animation due to a bug in the first subtree animation
          ),
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
                final depth = _getDepth(node);

                return Transform.translate(
                  offset: Offset(
                    -(depth * 10.0) + 5,
                    0,
                  ), // To modify floor spacing, adjust the +int here (nodeTree global offset), and adjust 2 and 3 too
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...List.generate(
                        depth,
                        (i) => SizedBox(
                          width: 30, // 2
                          child: Center(
                            child: Container(
                              width: 1,
                              color: Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),
                      if (!isSporeNode)
                        SizedBox(
                          width: 40,
                          child: Transform.translate(
                            offset: const Offset(-5, 0), // 3
                            child: hasChildren
                                ? InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () => setState(
                                      () => controller.toggleNode(node),
                                    ),
                                    child: Center(
                                      child: AnimatedRotation(
                                        turns: node.isExpanded ? 0.25 : 0,
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        child: SvgPicture.asset(
                                          'assets/icons/triangle_full.svg',
                                          width: 12,
                                          height: 12,
                                        ),
                                      ),
                                    ),
                                  )
                                : _ShakeIcon(
                                    child: SvgPicture.asset(
                                      'assets/icons/triangle_empty.svg',
                                      width: 12,
                                      height: 12,
                                    ),
                                  ),
                          ),
                        ),
                      Expanded(
                        child: GestureDetector(
                          onLongPressStart: (details) {
                            widget.longPressCallback?.call(
                              typedNode.id,
                              details,
                            );
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
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                            .withValues(alpha: 0.1)
                                      : Colors.transparent,
                                ),
                                alignment: Alignment.centerLeft,
                                child: Transform.translate(
                                  offset: const Offset(10, 0),
                                  child: Text(
                                    formatNodeTitle(typedNode.content?['0']),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          typedNode.typeData?["dismiss"] == true
                                          ? Colors.grey.withValues(alpha: 0.5)
                                          : Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
                                    ),
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

class _ShakeIcon extends StatefulWidget {
  final Widget child;
  const _ShakeIcon({required this.child});

  @override
  State<_ShakeIcon> createState() => _ShakeIconState();
}

/// Animation made with ClaudeAI
class _ShakeIconState extends State<_ShakeIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final Animation<double> _shake = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.5), weight: 15),
    TweenSequenceItem(tween: Tween(begin: 0.5, end: -0.5), weight: 20),
    TweenSequenceItem(tween: Tween(begin: -0.5, end: 0.25), weight: 20),
    TweenSequenceItem(tween: Tween(begin: 0.25, end: 0.0), weight: 45),
  ]).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => {_controller.forward(from: 0)},
      child: Center(
        child: AnimatedBuilder(
          animation: _shake,
          builder: (context, child) =>
              Transform.rotate(angle: _shake.value, child: child),
          child: widget.child,
        ),
      ),
    );
  }
}
