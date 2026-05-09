import "package:flutter/material.dart";
import "package:mycelium/ui/widgets/api_status_dot_widget.dart";
import "package:mycelium/ui/widgets/app_bar.dart";
import "package:mycelium/ui/widgets/confirmation_dialog.dart";
import "package:mycelium/data/models/node.dart";
import "package:mycelium/viewmodels/deleted_nodes_viewmodel.dart";
import "package:provider/provider.dart";

class DeletedNodesPage extends StatefulWidget {
  @override
  State<DeletedNodesPage> createState() => _DeletedNodesPageState();
}

class _DeletedNodesPageState extends State<DeletedNodesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeletedNodesViewmodel>().getDeletedNodes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DeletedNodesViewmodel>();
    final sorted = [...vm.deletedNodes]
      ..sort((a, b) => (b.deletedAt ?? 0).compareTo(a.deletedAt ?? 0));
    return Scaffold(
      appBar: MyAppBar(
        titleText: "Deleted nodes",
        actions: [
          ApiStatusDotWidget(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DeletedNodesViewmodel>().getDeletedNodes(),
          ),
        ],
      ),
      body: SafeArea(
        child: sorted.isEmpty
            ? const Center(child: Text("No deleted nodes"))
            : ListView.builder(
                itemCount: sorted.length,
                itemBuilder: (context, index) {
                  final node = sorted[index];
                  return _NodeTile(
                    node: node,
                    typeName: vm.getNodeTypeName(node.type),
                    onTap: () async {
                      final confirm = await ConfirmationDialog.show(
                        context,
                        title: "Restore node",
                        text: "Do you want to restore this node?",
                      );
                      if (confirm) await vm.restoreNode(node.id);
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _NodeTile extends StatelessWidget {
  final Node node;
  final String typeName;
  final VoidCallback onTap;
  const _NodeTile({required this.node, required this.typeName, required this.onTap});

  String _preview() {
    final fields = node.content;
    if (fields == null || fields.isEmpty) return "No content";
    final text = fields.values.whereType<String>().join(" ");
    return text.length > 200 ? "${text.substring(0, 200)}..." : text;
  }

  String _formatDate(int? ms) {
    if (ms == null) return "Unknown";
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(typeName),
      subtitle: Text(_preview()),
      trailing: Text(
        _formatDate(node.deletedAt),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
