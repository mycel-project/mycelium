import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/collection.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/data/repositories/review_repository.dart';
import 'package:mycelium/data/services/api_service.dart';
import 'package:mycelium/data/services/collection_service.dart';
import 'package:mycelium/data/services/node_service.dart';
import 'package:mycelium/data/services/review_service.dart';
import 'package:mycelium/domain/app_coordinator.dart';
import 'package:mycelium/domain/node_usecase.dart';
import 'package:mycelium/domain/review_usecase.dart';
import 'package:mycelium/viewmodels/api_viewmodel.dart';
import 'package:mycelium/viewmodels/collections_viewmodel.dart';
import 'package:mycelium/viewmodels/home_viewmodel.dart';
import 'package:mycelium/viewmodels/md_editor_view_model.dart';
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
  final nodeStore = NodeStore();

  final reviewStore = ReviewStore();

  final reviewService = ReviewService(
    apiService,
  ); // No direct access to reviewService, only through reviewUseCase?

  final nodeRepository = NodeRepository(nodeService);
  final colId = collectionStore.currentCollection?.id;
  if (colId != null) {
    nodeRepository.loadNodes(colId);
  }
  final reviewRepository = ReviewRepository(reviewService);
  await nodeRepository.getNodeTypes();
  await reviewRepository.getClozeRegex();
  final reviewUseCase = ReviewUseCase(
    reviewService,
    nodeStore,
    reviewStore,
    collectionStore,
    reviewRepository,
  );
  final nodeUseCase = NodeUseCase(nodeService, nodeStore, nodeRepository);
  final appCoordinator = AppCoordinator(collectionStore, nodeRepository, nodeStore);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => collectionView),
        ChangeNotifierProvider(create: (_) => collectionStore),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(
            apiService: apiService,
            reviewStore: reviewStore,
            nodeUseCase: nodeUseCase,
            nodeStore: nodeStore,
            nodeRepository: nodeRepository,
            collectionStore: collectionStore,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ApiViewModel(apiStore, apiService),
        ),
        ChangeNotifierProvider(create: (_) => apiStore),
        ChangeNotifierProvider(create: (_) => nodeStore),
        ChangeNotifierProvider(
          create: (_) => MdEditorViewModel(
            nodeService: nodeService,
            nodeStore: nodeStore,
            nodeRepository: nodeRepository,
            reviewUseCase: reviewUseCase,
            reviewRepository: reviewRepository,
            reviewStore: reviewStore,
          ),
        ),
        ChangeNotifierProvider(create: (_) => reviewStore),
        Provider(create: (_) => reviewUseCase),
        Provider(create: (_) => appCoordinator),
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
