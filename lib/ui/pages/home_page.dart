import 'package:flutter/material.dart';
import 'package:mycelium/ui/widgets/app_bar.dart';
import 'package:mycelium/viewmodels/collections_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:mycelium/viewmodels/home_viewmodel.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.read<HomeViewModel>();

    return Scaffold(     
      appBar: MyAppBar(
        titleText: context.watch<CollectionsViewModel>().selectedCollection?.name ?? "No collection selected",
        actions: [
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
      body: Text("placeholder"),
      drawer: Drawer(
        child: Text("salut")
      )
    );
  }
}
