import "package:flutter/material.dart";
import "package:mycelium/ui/widgets/api_status_dot_widget.dart";
import "package:mycelium/ui/widgets/app_bar.dart";
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
        child: vm.deletedNodes.isEmpty
            ? const Center(child: Text("No deleted nodes"))
            : ListView.builder(
                itemCount: vm.deletedNodes.length,
                itemBuilder: (context, index) {
                  final node = vm.deletedNodes[index];
                  return _NodeTile(node: node);
                },
              ),
      ),
    );
  }
}

class _NodeTile extends StatelessWidget {
  final Node node;
  const _NodeTile({required this.node});

  String _preview() {
    final fields = node.content;
    if (fields == null || fields.isEmpty) return "No content";
    final text = fields.values.whereType<String>().join(" ");
    return text.length > 200 ? "${text.substring(0, 200)}..." : text;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("Type ${node.type}"),
      subtitle: Text(_preview()),
    );
  }
}
