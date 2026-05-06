import 'package:flutter/material.dart';
import 'package:mycelium/core/debug/network_logger.dart';
import 'package:mycelium/core/injection.dart';
import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/notifications/notification_listener.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/domain/api_status.dart';
import 'package:mycelium/domain/init_api_usecase.dart';
import 'package:mycelium/domain/init_data_usecase.dart';
import 'package:mycelium/ui/pages/api_config_page.dart';
import 'package:mycelium/viewmodels/api_viewmodel.dart';
import 'package:mycelium/viewmodels/collections_viewmodel.dart';
import 'package:mycelium/viewmodels/home_viewmodel.dart';
import 'package:mycelium/viewmodels/md_editor_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'ui/pages/home_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences preferences = await SharedPreferences.getInstance();
  // await preferences.clear();

  await setup();

  final apiStatus = await sl<InitApiUseCase>().execute();
  if (apiStatus == ApiStatus.reachable) {
    await sl<InitDataUseCase>().execute();
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
        ChangeNotifierProvider(create: (_) => sl<NetworkLogger>()),
        ChangeNotifierProvider(create: (_) => sl<NotificationBus>()),
      ],
      child: MyApp(apiStatus: apiStatus),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ApiStatus apiStatus;
  const MyApp({super.key, required this.apiStatus});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      config: ToastificationConfig(
        alignment: Alignment.bottomLeft,
        animationDuration: Duration(milliseconds: 300),
      ),
      child: MaterialApp(
        title: 'Mycelium',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        ),
        home: MyceliumNotificationListener(
          child: apiStatus == ApiStatus.emptyUrl ? ApiConfigPage() : HomePage(),
        ),
      ),
    );
  }
}
