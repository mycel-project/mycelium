import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/data/models/node_type.dart';
import 'package:mycelium/ui/widgets/app_bar.dart';
import 'package:mycelium/ui/widgets/md_editor.dart';
import 'package:mycelium/ui/widgets/node_tree.dart';
import 'package:mycelium/viewmodels/nodes_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:mycelium/viewmodels/home_viewmodel.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.read<HomeViewModel>();
    final apiStore = context.watch<ApiStore>();       

    return Scaffold(     
      appBar: MyAppBar(
        titleText: context.watch<CollectionStore>().currentCollection?.name ?? "No collection selected",
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 7),
            child: GestureDetector(
              onTap: () =>  vm.goToApiConfig(context),
              child: Icon(
                (apiStore.isReachable ?? false) ? Icons.circle : Icons.circle,
                color: apiStore.isReachable == null
                ? Colors.grey
                : (apiStore.isReachable! ? Colors.green : Colors.red),
                size: 16,
              ),
            ),
          ),
          PopupMenuButton(
            onSelected: (value) {
              if (value == 1) {
                vm.goToCollections(context);
              } else if (value == 2) {
                vm.goToApiConfig(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 1, child: Text("Manage collections")),
              PopupMenuItem(value: 2, child: Text("API configuration")),
            ],
          ),
        ],
      ),
      body: MdEditor(),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const _DrawerHeader(),
              const Divider(height: 1),
              Expanded(
                child: NodeTree(
                  nodes: context.watch<NodesViewModel>().nodes,
                  isSpore: (node) {
                    final vm = context.read<NodesViewModel>();
                    final type = vm.nodeTypes.firstWhere(
                      (t) => t.key == node.type,
                      orElse: () => NodeType(label: "", key: -1),
                    );
                    return type.label == "SPORE";
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nodes",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
