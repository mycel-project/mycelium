import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/ui/widgets/app_bar.dart';
import 'package:mycelium/ui/widgets/confirmation_dialog.dart';
import 'package:mycelium/viewmodels/collections_viewmodel.dart';
import 'package:provider/provider.dart';

class CollectionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(titleText: "Collections manager"),
      body: Padding(
        padding: const EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Collections",
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Padding(padding: EdgeInsetsGeometry.all(16)),
            Expanded(child: CollectionsList()),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => CreateCollectionDialog(
                    onSubmit: (name) async {
                      await context
                          .read<CollectionsViewModel>()
                          .createCollection(name);
                    },
                  ),
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
  @override
  State<CollectionsList> createState() => _CollectionsListState();
}

class _CollectionsListState extends State<CollectionsList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CollectionsViewModel>().loadCollections();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CollectionsViewModel>();
    final store = context.watch<CollectionStore>();
    return SafeArea(
      child: ListView.builder(
        itemCount: vm.collections.length,
        itemBuilder: (context, index) {
          final collection = vm.collections[index];
          return Center(
            child: ListTile(
              tileColor: collection.id == store.currentCollection?.id
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                  : null,
              onTap: () {
                vm.setCollection(collection.id);
              },
              onLongPress: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) {
                    return SafeArea(
                      child: Wrap(
                        children: [
                          ListTile(
                            leading: Icon(Icons.edit),
                            title: Text("Rename"),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  final controller = TextEditingController(
                                    text: collection.name,
                                  );
                                  return SimpleDialog(
                                    title: Text("New name"),
                                    children: [
                                      Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: TextField(
                                            controller: controller,
                                            autofocus: true,
                                            onSubmitted: (value) async {
                                              await vm.renameCollection(
                                                collection.id,
                                                value,
                                              );
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                            onTap: () async {
                              final confirm = await ConfirmationDialog.show(
                                context,
                                title: "Delete confirmation",
                                text:
                                    "Delete collection ${collection.name} and all data associated?",
                                destructive: true,
                              );
                              Navigator.pop(context);
                              if (confirm == true) {
                                vm.deleteCollection(collection.id);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              title: Text(
                collection.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              trailing: Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}

class CreateCollectionDialog extends StatefulWidget {
  final Function(String name) onSubmit;

  const CreateCollectionDialog({super.key, required this.onSubmit});

  @override
  State<CreateCollectionDialog> createState() => _CreateCollectionDialogState();
}

class _CreateCollectionDialogState extends State<CreateCollectionDialog> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text("Collection name"),
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: controller,
              autofocus: true,
              onSubmitted: (value) async {
                await widget.onSubmit(value);
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ],
    );
  }
}
