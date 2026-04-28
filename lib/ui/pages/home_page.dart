import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/models/node_type.dart';
import 'package:mycelium/domain/review_usecase.dart';
import 'package:mycelium/ui/pages/api_config_page.dart';
import 'package:mycelium/ui/pages/collections_page.dart';
import 'package:mycelium/ui/widgets/app_bar.dart';
import 'package:mycelium/ui/widgets/md_editor.dart';
import 'package:mycelium/ui/widgets/no_collection_widget.dart';
import 'package:mycelium/ui/widgets/no_more_reviews_widget.dart';
import 'package:mycelium/ui/widgets/no_node_widget.dart';
import 'package:mycelium/ui/widgets/node_tree.dart';
import 'package:mycelium/viewmodels/launch_review_button_viewmodel.dart';
import 'package:mycelium/viewmodels/nodes_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:mycelium/viewmodels/home_viewmodel.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final apiStore = context.watch<ApiStore>();
    return ChangeNotifierProvider(
      create: (_) => LaunchReviewButtonViewmodel(context.read<ReviewUseCase>()),
      child: Scaffold(
        appBar: MyAppBar(
          titleText:
              context.watch<CollectionStore>().currentCollection?.name ??
              "No collection selected",
          actions: [
            IconButton(
              onPressed: () {
                context.read<ReviewUseCase>().handleNextReview();
              },
              icon: const Icon(Icons.school),
            ),
            IconButton(
              onPressed: () => vm.connectionStatusClick(),
              splashRadius: 20,
              icon: vm.isCheckingConnection
                  ? const Icon(Icons.sync, size: 16, color: Colors.white)
                  : apiStore.isReachable == null
                  ? const Icon(Icons.circle, size: 16, color: Colors.grey)
                  : apiStore.isReachable == true
                  ? const Icon(Icons.circle, size: 16, color: Colors.green)
                  : const Icon(Icons.refresh, size: 16, color: Colors.red),
            ),
            PopupMenuButton(
              onSelected: (value) {
                if (value == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CollectionsPage()),
                  );
                } else if (value == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ApiConfigPage()),
                  );
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(value: 1, child: Text("Manage collections")),
                PopupMenuItem(value: 2, child: Text("API configuration")),
              ],
            ),
          ],
        ),
        body: vm.noMoreReviewsFlag
            ? NoMoreReviewsWidget(onDismiss: vm.dismissNoMoreReviews)
            : context.watch<NodeStore>().currentNode != null
            ? MdEditor()
            : context.watch<CollectionStore>().currentCollection == null
            ? NoCollectionWidget()
            : NoNodeWidget(),
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
                    clickCallback: (int value) {
                      context.read<NodesViewModel>().selectNode(value);
                    },
                  ),
                ),
              ],
            ),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
