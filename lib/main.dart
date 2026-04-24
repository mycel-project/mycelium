import 'package:flutter/material.dart';
import 'package:mycelium/core/app_config.dart';
import 'package:mycelium/data/services/collection_service.dart';
import 'package:mycelium/data/services/node_service.dart';
import 'package:mycelium/viewmodels/collections_viewmodel.dart';
import 'package:mycelium/viewmodels/home_viewmodel.dart';
import 'package:mycelium/viewmodels/nodes_viewmodel.dart';
import 'ui/pages/home_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig();
  await config.init();
  final collectionService = CollectionService(config);
  final nodeService = NodeService(config);
  final collectionView = CollectionsViewModel(collectionService);
  final nodeView = NodesViewModel(nodeService, collectionView);  
  collectionView.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => collectionView),
        ChangeNotifierProvider(create: (_) => nodeView),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => config),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      ),
      home: HomePage(),
    );
  }
}
