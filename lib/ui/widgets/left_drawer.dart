// ui/widgets/left_drawer.dart

import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/data/models/node_type.dart';
import 'package:mycelium/ui/widgets/confirmation_dialog.dart';
import 'package:mycelium/ui/widgets/input_dialog.dart';
import 'package:mycelium/ui/widgets/node_tree.dart';
import 'package:mycelium/viewmodels/home_viewmodel.dart';
import 'package:provider/provider.dart';

class LeftDrawer extends StatelessWidget {
  final HomeViewModel vm;
  final VoidCallback? onClose;
  const LeftDrawer({super.key, required this.vm, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _DrawerHeader(vm: vm, onClose: onClose),
            const Divider(height: 1),
            Expanded(
              child: NodeTree(
                nodes: vm.getNodes(),
                isSpore: (node) {
                  final type = vm.getNodeTypes().firstWhere(
                    (t) => t.key == node.type,
                    orElse: () => NodeType(label: "", key: -1),
                  );
                  return type.label == "SPORE";
                },
                popOnClick:  true,
                clickCallback: (int value) => vm.navigateTo(value),
                longPressCallback:
                    (int nodeId, LongPressStartDetails details) async {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final position = details.globalPosition;
                      double dx = position.dx - 75;
                      if (dx < 8) dx = 8;

                      final selected = await showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(
                          dx,
                          position.dy,
                          screenWidth - dx,
                          position.dy,
                        ),
                        items: const [
                          PopupMenuItem(value: 'delete', child: Text("Delete")),
                          PopupMenuItem(value: 'rename', child: Text("Rename")),
                        ],
                      );

                      if (!context.mounted) return;

                      if (selected == 'delete') {
                        final result = await ConfirmationDialog.show(
                          context,
                          title: "Delete confirmation",
                          text: "Delete this node and all its children?",
                          destructive: true,
                        );
                        if (!context.mounted) return;
                        if (result.confirmed == true)
                          await vm.deleteNode(nodeId);
                      } else if (selected == 'rename') {
                        final name = await vm.getNodeTitle(nodeId) ?? "";
                        if (!context.mounted) return;
                        await showInputDialogWithRetry(
                          context: context,
                          title: "Enter new title",
                          placeholder: "Node title",
                          initialValue: name,
                          onSubmit: (newName) async =>
                              await vm.updateNodeTitle(nodeId, newName),
                        );
                      }
                    },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final HomeViewModel vm;
  final VoidCallback? onClose;
  const _DrawerHeader({required this.vm, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.watch<CollectionStore>().currentCollection?.name ??
                  "No collection",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _iconButton(context, Icons.search, () => onClose?.call()),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == "url") {
                    if (!context.mounted) return;
                    await showInputDialogWithRetry(
                      context: context,
                      title: "Enter ressource URL",
                      placeholder: "https://example.com/page",
                      onSubmit: (url) => vm.fetchRessourceFromUrl(url),
                    );
                    if (!context.mounted) return;
                    onClose?.call();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'url',
                    child: Text("New ressource from url"),
                  ),
                ],
                style: ButtonStyle(
                  shape: const WidgetStatePropertyAll(CircleBorder()),
                  backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
                ),
                icon: const Icon(Icons.post_add, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: InkResponse(
          onTap: onTap,
          radius: 18,
          splashColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.2),
          highlightShape: BoxShape.circle,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              size: 18,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ),
      ),
    );
  }
}
