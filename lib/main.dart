import 'package:flutter/material.dart';
import 'package:mycelium/core/debug/network_logger.dart';
import 'package:mycelium/core/editor/editor_backend.dart';
import 'package:mycelium/core/injection.dart';
import 'package:mycelium/core/notifications/notification_listener.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/app_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/core/stores/scroll_position_store.dart';
import 'package:mycelium/core/stores/user_store.dart';
import 'package:mycelium/domain/check_app_update_usecase.dart';
import 'package:mycelium/domain/init_api_usecase.dart';
import 'package:mycelium/ui/widgets/window_initializer.dart';
import 'package:mycelium/utils/device.dart';
import 'package:mycelium/viewmodels/about_viewmodel.dart';
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
  await sl<AppStore>().init();
  await sl<InitApiUseCase>()
      .initApiUrl(); // Make sure we retrieve the API URL stored in preferences to display the correct start screen.

  sl<CheckAppUpdateUseCase>().execute();
  sl<InitApiUseCase>().execute();

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
        ChangeNotifierProvider(create: (_) => sl<UserStore>()),
        ChangeNotifierProvider(create: (_) => sl<SettingViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<DeletedNodesViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<AboutViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<AppStore>()),
        ChangeNotifierProvider(create: (_) => sl<ScrollPositionStore>()),
        Provider(create: (_) => sl<EditorBackend>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
              TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
            },
          ),
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
          child: Device.isDesktop
              ? WindowInitializer(child: const HomePage())
              : const HomePage(),
        ),
      ),
    );
  }
}
