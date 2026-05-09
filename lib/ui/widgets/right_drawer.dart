import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/models/node.dart';
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
      trailing: GestureDetector(
        onTap: () => _showPriorityPicker(context),
        child: Chip(
          label: Text("${node.priority}"),
        ),
      ),
    );
  }

  void _showPriorityPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Set priority"),
        content: TextField(
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "0 - 100",
          ),
          onSubmitted: (value) {
            final parsed = int.tryParse(value);
            if (parsed != null && parsed >= 0 && parsed <= 100) {
              vm.updatePriority(node.id, parsed);
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }
}
