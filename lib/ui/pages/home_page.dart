import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/domain/api_status.dart';
import 'package:mycelium/ui/pages/about_page.dart';
import 'package:mycelium/ui/pages/api_config_page.dart';
import 'package:mycelium/ui/pages/collections_page.dart';
import 'package:mycelium/ui/pages/deleted_nodes_page.dart';
import 'package:mycelium/ui/pages/settings_page.dart';
import 'package:mycelium/ui/widgets/api_not_reachable_widget.dart';
import 'package:mycelium/ui/widgets/api_status_dot_widget.dart';
import 'package:mycelium/ui/widgets/app_bar.dart';
import 'package:mycelium/ui/widgets/left_drawer.dart';
import 'package:mycelium/ui/widgets/md_editor.dart';
import 'package:mycelium/ui/widgets/no_collection_widget.dart';
import 'package:mycelium/ui/widgets/no_more_reviews_widget.dart';
import 'package:mycelium/ui/widgets/no_node_widget.dart';
import 'package:mycelium/ui/widgets/right_drawer.dart';
import 'package:mycelium/utils/device.dart';
import 'package:mycelium/utils/responsive.dart';
import 'package:provider/provider.dart';
import 'package:mycelium/viewmodels/home_viewmodel.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final apiStore = context.watch<ApiStore>();
    return Scaffold(
      drawerEdgeDragWidth: 200,
      appBar: MyAppBar(
        leading:
        !Device.isMobile
        ?
        Builder(
            builder: (context) => IconButton(
              icon: SvgPicture.asset(
                  'assets/icons/panel.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              onPressed: () {
                if (!Responsive.isDesktop(context)) {
                  Scaffold.of(context).openDrawer();
                } else {
                  vm.toggleLeftPanel();
                }
              },
            ),
          )
         :
        null,
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
          if (!Device.isMobile)
          Builder(
            builder: (context) => IconButton(
              iconSize: 24,        // taille de l'icone
              padding: const EdgeInsets.all(14), // zone cliquable = 24 + 12*2 = 48px
              constraints: const BoxConstraints(),
              icon: Transform.rotate(
                angle: 3.1416,
                child: SvgPicture.asset(
                  'assets/icons/panel.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              onPressed: () {
                if (!Responsive.isDesktop(context)) {
                  Scaffold.of(context).openEndDrawer();
                } else {
                  vm.toggleEndPanel();
                }
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: vm.noMoreReviewsFlag
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
          ),
          if (!Responsive.isMobile(context))
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: AnimatedSlide(
              offset: vm.isLeftPanelOpen ? Offset.zero : const Offset(-1, 0),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: Container(
                width: 400,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: LeftDrawer(vm: vm),
              ),
            ),
          ),
          if (!Responsive.isMobile(context))
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: AnimatedSlide(
              offset: vm.isEndPanelOpen ? Offset.zero : const Offset(1, 0),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: Container(
                width: 300,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: const RightDrawer(),
              ),
            ),
          ),
        ],
      ),
      drawer: Responsive.isMobile(context) ? LeftDrawer(vm: vm, onClose: () => Navigator.pop(context)) : null,
      endDrawer: Responsive.isMobile(context) ? const RightDrawer() : null,
      onDrawerChanged: (isOpened) {
        if (isOpened) vm.refreshNodes();
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }
}
