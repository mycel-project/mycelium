import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/collection.dart';
import 'package:mycelium/data/services/api_service.dart';
import 'package:mycelium/data/services/collection_service.dart';
import 'package:mycelium/data/services/node_service.dart';
import 'package:mycelium/viewmodels/api_viewmodel.dart';
import 'package:mycelium/viewmodels/collections_viewmodel.dart';
import 'package:mycelium/viewmodels/home_viewmodel.dart';
import 'package:mycelium/viewmodels/nodes_viewmodel.dart';
import 'ui/pages/home_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiStore = ApiStore();
  await apiStore.init();
  final apiService = ApiService(apiStore);

  final collectionService = CollectionService(apiService);
  final collectionStore = CollectionStore();

  final collectionView = CollectionsViewModel(
    collectionService,
    collectionStore,
    apiStore,
  );
  // restore selected collection
  try {
    final savedId = await collectionStore.getSavedId();
    final result = await collectionService.getCollections();

    List<Collection> collections = [];
    if (result is ApiSuccess<List<Collection>>) {
      collections = result.data;
    } else if (result is ApiError) {
      print("Can't get collections: ${result.code}");
    }
    if (savedId != null && collections.isNotEmpty) {
      final candidates = collections.where((c) => c.id == savedId);
      if (candidates.isNotEmpty) {
        collectionStore.selectCollection(candidates.first);
      }
    }
    await collectionView.init();
  } catch (e) {
    print("No access to API");
  }

  final nodeService = NodeService(apiService);
  final nodeViewModel = NodesViewModel(nodeService, collectionStore);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => collectionView),
        ChangeNotifierProvider(create: (_) => collectionStore),
        ChangeNotifierProvider(create: (_) => nodeViewModel),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(
          create: (_) => ApiViewModel(apiStore, apiService),
        ),
        ChangeNotifierProvider(create: (_) => apiStore),
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
