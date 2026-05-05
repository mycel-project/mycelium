import 'package:flutter/material.dart';
import 'package:mycelium/core/injection.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/data/repositories/review_repository.dart';
import 'package:mycelium/domain/init_api_usecase.dart';
import 'package:mycelium/domain/init_collections_usecase.dart';
import 'package:mycelium/viewmodels/api_viewmodel.dart';
import 'package:mycelium/viewmodels/collections_viewmodel.dart';
import 'package:mycelium/viewmodels/home_viewmodel.dart';
import 'package:mycelium/viewmodels/md_editor_view_model.dart';
import 'ui/pages/home_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();

  final isReachable = await sl<InitApiUseCase>().execute();
  if (isReachable) {
    await sl<InitCollectionsUseCase>().execute();
    await sl<NodeRepository>().getNodeTypes();
    await sl<ReviewRepository>().getClozeRegex();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<CollectionsViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<ApiViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<HomeViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<MdEditorViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<CollectionStore>()),
        ChangeNotifierProvider(create: (_) => sl<ApiStore>()),
        ChangeNotifierProvider(create: (_) => sl<NodeStore>()),
        ChangeNotifierProvider(create: (_) => sl<ReviewStore>()),
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
