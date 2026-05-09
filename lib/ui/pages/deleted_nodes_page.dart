import "package:flutter/material.dart";
import "package:mycelium/ui/widgets/api_status_dot_widget.dart";
import "package:mycelium/ui/widgets/app_bar.dart";
import "package:mycelium/ui/widgets/confirmation_dialog.dart";
import "package:mycelium/ui/widgets/node_tree.dart";
import "package:mycelium/viewmodels/deleted_nodes_viewmodel.dart";
import "package:provider/provider.dart";

class DeletedNodesPage extends StatefulWidget {
  const DeletedNodesPage({super.key});

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
    return Scaffold(
      appBar: MyAppBar(
        titleText: "Deleted nodes",
        actions: [
          ApiStatusDotWidget(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<DeletedNodesViewmodel>().getDeletedNodes(),
          ),
        ],
      ),
      body: SafeArea(
        child: vm.deletedNodes.isEmpty
            ? const Center(child: Text("No deleted nodes"))
            : NodeTree(
                nodes: vm.deletedNodes,
                popOnClick: false,
                subtitleBuilder: (node) {
                  return vm.formatDeletedAt(node);
                },
                clickCallback: (id) async {
                  final confirm = await ConfirmationDialog.show(
                    context,
                    title: "Restore node",
                    text: "Do you want to restore this node?",
                  );
                  if (!context.mounted) return;
                  if (confirm) await vm.restoreNode(id);
                },
              ),
      ),
    );
  }
}
