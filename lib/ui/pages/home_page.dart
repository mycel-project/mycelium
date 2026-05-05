import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/models/node_type.dart';
import 'package:mycelium/domain/api_status.dart';
import 'package:mycelium/domain/review_usecase.dart';
import 'package:mycelium/ui/pages/api_config_page.dart';
import 'package:mycelium/ui/pages/collections_page.dart';
import 'package:mycelium/ui/widgets/app_bar.dart';
import 'package:mycelium/ui/widgets/confirmation_dialog.dart';
import 'package:mycelium/ui/widgets/input_dialog.dart';
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
              ? 
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                ),
              )
              :
              Icon(
                size: 16,
                switch (apiStore.apiStatus) {
                  ApiStatus.unknown || ApiStatus.emptyUrl => Icons.circle,
                  ApiStatus.reachable => Icons.circle,
                  ApiStatus.unreachable => Icons.circle,
                },
                color: switch (apiStore.apiStatus) {
                  ApiStatus.unknown || ApiStatus.emptyUrl => Colors.grey,
                  ApiStatus.reachable => Colors.green,
                  ApiStatus.unreachable => Colors.red,
                },
              )
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
                _DrawerHeader(vm: vm),
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
                              PopupMenuItem(
                                value: 'rename',
                                child: Text("Rename"),
                              ),
                            ],
                          );
                          if (selected == 'delete') {
                            final confirm = await ConfirmationDialog.show(
                              context,
                              title: "Delete confirmation",
                              text: "Delete this node and all its children?",
                              destructive: true,
                            );
                            if (!context.mounted) return;
                            if (confirm == true) {
                              await vm.deleteNode(nodeId);
                            }
                          } else if (selected == "rename") {
                            final name = await vm.getNodeTitle(nodeId) ?? "";
                            final newName = await showInputDialog(
                              context: context,
                              title: "Enter new title",
                              placeholder: "Node title",
                              initialValue: name,
                            );
                            vm.updateNodeTitle(nodeId, newName ?? "");
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
          FocusManager.instance.primaryFocus?.unfocus();
        },
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final HomeViewModel vm;
  const _DrawerHeader({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.watch<CollectionStore>().currentCollection?.name ??
                  "No collection selected",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _iconButton(context, Icons.search, () {
                print("salut");
                Navigator.pop(context);
              }),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == "url") {
                    final request = await showInputDialog(
                      context: context,
                      title: "Enter ressource URL",
                      placeholder: "https://example.com/page",
                    );
                    await vm.fetchRessourceFromUrl(request);
                    Navigator.pop(context);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'url',
                    child: Text("New ressource from url"),
                  ),
                ],
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(const CircleBorder()),
                  backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
                ),
                icon: const Icon(Icons.post_add, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: InkResponse(
          onTap: onTap,
          radius: 18,
          splashColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.2),
          highlightShape: BoxShape.circle,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              size: 18,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ),
      ),
    );
  }
}
