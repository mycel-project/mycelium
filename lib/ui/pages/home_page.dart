import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/data/models/node_type.dart';
import 'package:mycelium/domain/api_status.dart';
import 'package:mycelium/ui/pages/about_page.dart';
import 'package:mycelium/ui/pages/api_config_page.dart';
import 'package:mycelium/ui/pages/collections_page.dart';
import 'package:mycelium/ui/pages/deleted_nodes_page.dart';
import 'package:mycelium/ui/pages/settings_page.dart';
import 'package:mycelium/ui/widgets/api_not_reachable_widget.dart';
import 'package:mycelium/ui/widgets/api_status_dot_widget.dart';
import 'package:mycelium/ui/widgets/app_bar.dart';
import 'package:mycelium/ui/widgets/confirmation_dialog.dart';
import 'package:mycelium/ui/widgets/input_dialog.dart';
import 'package:mycelium/ui/widgets/md_editor.dart';
import 'package:mycelium/ui/widgets/no_collection_widget.dart';
import 'package:mycelium/ui/widgets/no_more_reviews_widget.dart';
import 'package:mycelium/ui/widgets/no_node_widget.dart';
import 'package:mycelium/ui/widgets/node_tree.dart';
import 'package:mycelium/ui/widgets/right_drawer.dart';
import 'package:provider/provider.dart';
import 'package:mycelium/viewmodels/home_viewmodel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final apiStore = context.watch<ApiStore>();
    return Scaffold(
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
              vm.handleNextReview();
            }
            : null,
            icon: const Icon(Icons.school),
          ),
          const ApiStatusDotWidget(),
          PopupMenuButton(
            onSelected: (value) {
              if (value == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CollectionsPage()),
                );
              } else if (value == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ApiConfigPage()),
                );
              } else if (value == 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              } else if (value == 4) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeletedNodesPage()),
                );
              } else if (value == 5) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                );
              }
            },
            itemBuilder:  (BuildContext context) => const[
              PopupMenuItem(value: 1, child: Text("Manage collections")),
              PopupMenuItem(value: 2, child: Text("API configuration")),
              PopupMenuItem(value: 3, child: Text("Settings")),
              PopupMenuItem(value: 4, child: Text("Deleted nodes")),
              PopupMenuItem(value: 5, child: Text("About")),
            ],
          ),
        ],
      ),
      body: vm.noMoreReviewsFlag
      ? NoMoreReviewsWidget(onDismiss: vm.dismissNoMoreReviews)
      : context.watch<NodeStore>().currentNode != null
      ? MdEditor()
      : apiStore.apiStatus != ApiStatus.reachable
      ? ApiNotReachableWidget()
      : context.watch<CollectionStore>().currentCollection == null
      ? NoCollectionWidget()
      : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (vm.currentCollectionName() != null)
            Text(
              vm.currentCollectionName()!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            NoNodeWidget(),
          ],
        ),
      ),
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
                      if (!context.mounted) return;
                      final result = await ConfirmationDialog.show(
                        context,
                        title: "Delete confirmation",
                        text: "Delete this node and all its children?",
                        destructive: true,
                      );
                      if (!context.mounted) return;
                      if (result.confirmed == true) {
                        await vm.deleteNode(nodeId);
                      }
                    } else if (selected == "rename") {
                      final name = await vm.getNodeTitle(nodeId) ?? "";
                      if (!context.mounted) return;
                      await showInputDialogWithRetry(
                        context: context,
                        title: "Enter new title",
                        placeholder: "Node title",
                        initialValue: name,
                        onSubmit: (newName) async => await vm.updateNodeTitle(nodeId, newName),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      endDrawer: const RightDrawer(),
      onDrawerChanged: (isOpened) {
        if (isOpened) vm.refreshNodes();
        FocusManager.instance.primaryFocus?.unfocus();
      },
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
                  "No collection",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _iconButton(context, Icons.search, () {
                Navigator.pop(context);
              }),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == "url") {
                    if (!context.mounted) return;
                    await showInputDialogWithRetry(
                      context: context,
                      title: "Enter ressource URL",
                      placeholder: "https://example.com/page",
                      onSubmit: (url) => vm.fetchRessourceFromUrl(url),
                    );
                    if (!context.mounted) return;
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
