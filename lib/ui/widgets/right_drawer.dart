import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/ui/widgets/adaptative_sheet.dart';
import 'package:mycelium/ui/widgets/priority_selector.dart';
import 'package:mycelium/ui/widgets/reps_calendar.dart';
import 'package:mycelium/ui/widgets/reschedule_widget.dart';
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
            Expanded(
              child: ListView(children: [CalendarTile(vm: vm)]),
            ),
            if (node != null) ...[
              _RightDrawerNodeHeader(node: node),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  children: [
                    _PriorityTile(node: node, vm: vm),
                    _DueTile(node: node, vm: vm),                    
                  ],
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
    await vm.getCalendar();
    if (!context.mounted) return;
    showAdaptiveSheet(context: context, child: RepsCalendar(reps: vm.calendar));
  }
}

class _DueTile extends StatelessWidget {
  final Node node;
  final HomeViewModel vm;
  const _DueTile({required this.node, required this.vm});

  int _daysDiff(int ts) {
    final now = DateTime.now();
    final due = DateTime.fromMillisecondsSinceEpoch(ts);
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(due.year, due.month, due.day);
    return target.difference(today).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.schedule),
      title: const Text("Due"),
      trailing: node.due != null
      ? Chip(
        label: Text("${_daysDiff(node.due!)}d",
        ),
      )
      : const SizedBox(),
      onTap: () => showRescheduleWidget(
        context,
        initialDate: node.due != null
        ? DateTime.fromMillisecondsSinceEpoch(node.due!)
        : null,
        onConfirm: (dateIso) => vm.rescheduleNode(node.id, dateIso),
      )
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
    if (vm.nodeCount < 500) {
      await vm.refreshPriorities();
    } // Above this limit, priorities are diluted enough that a full refresh is unnecessary I guess.
    if (!context.mounted) return;
    showAdaptiveSheet(context: context, child: PrioritySelector(
        nodes: vm.getNodes(),
        currentNodeId: node.id,
        onConfirm: (value) {
          vm.updatePriority(node.id, value);
          Navigator.pop(context);
        },
      )
    );
  }
}

