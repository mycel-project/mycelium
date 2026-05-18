import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/ui/widgets/priority_selector.dart';
import 'package:mycelium/ui/widgets/reps_calendar.dart';
import 'package:mycelium/viewmodels/home_viewmodel.dart';
import 'package:provider/provider.dart';

class RightDrawer extends StatelessWidget {
  const RightDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final node = context.watch<NodeStore>().currentNode;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const _RightDrawerReviewHeader(),
            const Divider(height: 1),
            Expanded(child: ListView(children: [CalendarTile(vm: vm)])),
            if (node != null) ...[
              _RightDrawerNodeHeader(node: node),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  children: [_PriorityTile(node: node, vm: vm)],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RightDrawerNodeHeader extends StatelessWidget {
  final Node node;
  const _RightDrawerNodeHeader({required this.node});

  @override
  Widget build(BuildContext context) {
    return const ListTile(title: Text("Current Node"));
  }
}

class _RightDrawerReviewHeader extends StatelessWidget {
  const _RightDrawerReviewHeader();

  @override
  Widget build(BuildContext context) {
    return const ListTile(title: Text("General"));
  }
}

class CalendarTile extends StatelessWidget {
  final HomeViewModel vm;

  const CalendarTile({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.calendar_month),
      title: const Text("Calendar"),
      onTap: () => _showRepsCalendar(context),
    );
  }

  void _showRepsCalendar(BuildContext context) async {
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: RepsCalendar(reps: vm.repsData),
        ),
      ),
    );
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

  void _showPriorityPicker(BuildContext context) async {
    if (vm.nodeCount < 500)
      await vm
          .refreshPriorities(); // Above this limit, priorities are diluted enough that a full refresh is unnecessary I guess.
    if (!context.mounted) return;
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
              vm.updatePriority(node.id, value);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
