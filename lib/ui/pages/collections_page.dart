import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/data/models/collection.dart';
import 'package:mycelium/ui/widgets/api_status_dot_widget.dart';
import 'package:mycelium/ui/widgets/app_bar.dart';
import 'package:mycelium/ui/widgets/confirmation_dialog.dart';
import 'package:mycelium/ui/widgets/input_dialog.dart';
import 'package:mycelium/utils/device.dart';
import 'package:mycelium/viewmodels/collections_viewmodel.dart';
import 'package:provider/provider.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        titleText: "Manage collections",
        actions: [
          ApiStatusDotWidget(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
            context.read<CollectionsViewModel>().loadCollections(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Collections",
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Padding(padding: EdgeInsetsGeometry.all(16)),
            Expanded(
              child: Center(
                child:
                context.watch<CollectionsViewModel>().collections.isNotEmpty
                ? const CollectionsList()
                : const Text("No collection"),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await showInputDialogWithRetry(
                  context: context,
                  title: "Collection name",
                  onSubmit: (name) => context
                  .read<CollectionsViewModel>()
                  .createCollection(name),
                );
              },
              child: Text("Create collection"),
            ),
          ],
        ),
      ),
    );
  }
}

class CollectionsList extends StatefulWidget {
  const CollectionsList({super.key});

  @override
  State<CollectionsList> createState() => _CollectionsListState();
}

class _CollectionsListState extends State<CollectionsList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CollectionsViewModel>().reloadIfEmpty();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CollectionsViewModel>();
    final store = context.watch<CollectionStore>();

    Widget manageCollection(Collection collection) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text("Rename"),
              onTap: () async {
                await showInputDialogWithRetry(
                  context: context,
                  title: "New name",
                  initialValue: collection.name,
                  onSubmit: (name) => vm.renameCollection(collection.id, name),
                );
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text("Delete", style: TextStyle(color: Colors.red)),
              onTap: () async {
                final result = await ConfirmationDialog.show(
                  context,
                  title: "Delete confirmation",
                  text:
                  "Delete collection ${collection.name} and all data associated?",
                  destructive: true,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                if (result.confirmed == true) {
                  vm.deleteCollection(collection.id);
                }
              },
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: ListView.builder(
        itemCount: vm.collections.length,
        itemBuilder: (context, index) {
          final collection = vm.collections[index];
          return Center(
            child: GestureDetector(
              onSecondaryTap: Device.isDesktop ?
              () => showModalBottomSheet(
                context: context,
                builder: (_) {
                  return manageCollection(collection);
                },
              )
              : null,
              child: ListTile(
                tileColor: collection.id == store.currentCollection?.id
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : null,
                onTap: () {
                  vm.setCollection(collection.id);
                  Navigator.pop(context);
                },
                onLongPress: !Device.isDesktop ? () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) {
                      return manageCollection(collection);
                    },
                  );
                } : null,
                title: Text(
                  collection.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
          );
        },
      ),
    );
  }
}
