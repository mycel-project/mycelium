import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/ui/widgets/priority_selector.dart';
import 'package:mycelium/viewmodels/home_viewmodel.dart';
import 'package:provider/provider.dart';

class RightDrawer extends StatelessWidget {
  const RightDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final node = context.watch<NodeStore>().currentNode;

    if (node == null) return const SizedBox.shrink();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _RightDrawerHeader(node: node),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                children: [_PriorityTile(node: node, vm: vm)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RightDrawerHeader extends StatelessWidget {
  final Node node;
  const _RightDrawerHeader({required this.node});

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(node.id.toString()));
  }
}

class _PriorityTile extends StatelessWidget {
  final Node node;
  final HomeViewModel vm;

  const _PriorityTile({required this.node, required this.vm});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.star_outline),
      title: const Text("Priority"),
      trailing: Chip(label: Text("${node.priority}")),
      onTap: () => _showPriorityPicker(context),
    );
  }

  void _showPriorityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: PrioritySelector(
            nodes: vm.getNodes(),
            currentNodeId: node.id,
            onConfirm: (value) {
              print(value);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
