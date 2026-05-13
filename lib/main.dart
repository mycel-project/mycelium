import 'package:flutter/material.dart';
import 'package:mycelium/core/debug/network_logger.dart';
import 'package:mycelium/core/injection.dart';
import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/notifications/notification_listener.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/app_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/core/stores/user_store.dart';
import 'package:mycelium/domain/api_health_monitor.dart';
import 'package:mycelium/domain/api_status.dart';
import 'package:mycelium/domain/init_api_usecase.dart';
import 'package:mycelium/domain/init_data_usecase.dart';
import 'package:mycelium/ui/pages/api_config_page.dart';
import 'package:mycelium/viewmodels/api_viewmodel.dart';
import 'package:mycelium/viewmodels/collections_viewmodel.dart';
import 'package:mycelium/viewmodels/deleted_nodes_viewmodel.dart';
import 'package:mycelium/viewmodels/home_viewmodel.dart';
import 'package:mycelium/viewmodels/md_editor_viewmodel.dart';
import 'package:mycelium/viewmodels/settings_viewmodel.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'ui/pages/home_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences preferences = await SharedPreferences.getInstance();
  // await preferences.clear();

  await setup();
  sl<ApiHealthMonitor>();
  await sl<AppStore>().init();

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
        ChangeNotifierProvider(create: (_) => sl<UserStore>()),
        ChangeNotifierProvider(create: (_) => sl<SettingViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<DeletedNodesViewmodel>()),
        ChangeNotifierProvider(create: (_) => sl<AppStore>()),
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
      config: const ToastificationConfig(
        alignment: Alignment.bottomLeft,
        animationDuration: Duration(milliseconds: 300),
      ),
      child: MaterialApp(
        title: 'Mycelium',
        theme: ThemeData(
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF3D7A6E),
            onPrimary: Color(0xFFFAF8F4),
            primaryContainer: Color(0xFFEDF5F3),
            onPrimaryContainer: Color(0xFF242E28),
            secondary: Color(0xFFB87A28),
            onSecondary: Color(0xFFFAF8F4),
            secondaryContainer: Color(0xFFFAF0E0),
            onSecondaryContainer: Color(0xFF242E28),
            error: Color(0xFFB84830),
            onError: Color(0xFFFAF8F4),
            errorContainer: Color(0xFFFFEDE8),
            onErrorContainer: Color(0xFF242E28),
            surface: Color(0xFFF7FBFA),
            onSurface: Color(0xFF242E28),
            onSurfaceVariant: Color(0xFF687068),
            outline: Color(0x1A232D28),
            outlineVariant: Color(0x2E232D28),
          ),
        ),
        home: MyceliumNotificationListener(
          child: apiStatus == ApiStatus.emptyUrl ? ApiConfigPage() : HomePage(),
        ),
      ),
    );
  }
}
