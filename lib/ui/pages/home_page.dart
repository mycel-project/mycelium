import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/models/node_type.dart';
import 'package:mycelium/domain/review_usecase.dart';
import 'package:mycelium/ui/pages/api_config_page.dart';
import 'package:mycelium/ui/pages/collections_page.dart';
import 'package:mycelium/ui/widgets/app_bar.dart';
import 'package:mycelium/ui/widgets/confirmation_dialog.dart';
import 'package:mycelium/ui/widgets/md_editor.dart';
import 'package:mycelium/ui/widgets/no_collection_widget.dart';
import 'package:mycelium/ui/widgets/no_more_reviews_widget.dart';
import 'package:mycelium/ui/widgets/no_node_widget.dart';
import 'package:mycelium/ui/widgets/node_tree.dart';
import 'package:mycelium/viewmodels/launch_review_button_viewmodel.dart';
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
        drawerEdgeDragWidth: 200,
        appBar: MyAppBar(
          titleText: "",
          actions: [
            IconButton(
              onPressed: vm.hasPreviousNodes()
                  ? () {
                      vm.previousNode();
                    }
                  : null,
              onLongPress: () {
                vm.openHistory();
              },
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              onPressed: vm.hasNextNodes()
                  ? () {
                      vm.nextNode();
                    }
                  : null,
              onLongPress: () {
                vm.openHistory();
              },
              icon: const Icon(Icons.chevron_right),
            ),
            IconButton(
              onPressed: vm.hasParent
                  ? () {
                      vm.upPress();
                    }
                  : null,
              onLongPress: () {
                vm.longUpPress();
              },
              icon: const Icon(Icons.arrow_upward),
            ),
            IconButton(
              onPressed: !vm.isCurrentNodeUnderReview()
                  ? () {
                      context.read<ReviewUseCase>().handleNextReview();
                    }
                  : null,
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
                    nodes: vm.getNodes(),
                    isSpore: (node) {
                      final type = vm.getNodeTypes().firstWhere(
                        (t) => t.key == node.type,
                        orElse: () => NodeType(label: "", key: -1),
                      );
                      return type.label == "SPORE";
                    },
                    clickCallback: (int value) {
                      vm.navigateTo(value);
                    },
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
                            items: [
                              PopupMenuItem(
                                value: 'delete',
                                child: Text("Delete"),
                              ),
                            ],
                          );
                          if (selected == 'delete') {
                            final confirm = await ConfirmationDialog.show(
                              context,
                              title: "Delete confirmation",
                              text: "Delete this node and all its children?",
                            );
                            if (!context.mounted) return;
                            if (confirm == true) {
                              await vm.deleteNode(nodeId);
                            }
                          }
                        },
                  ),
                ),
              ],
            ),
          ),
        ),
        onDrawerChanged: (isOpened) {
          if (isOpened) vm.refreshNodes();
        },
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
