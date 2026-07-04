import 'package:get_it/get_it.dart';
import 'package:mycelium/core/debug/network_logger.dart';
import 'package:mycelium/core/editor/editor_backend.dart';
import 'package:mycelium/core/editor/in_app_webview_backend.dart';
import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/app_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/navigation_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/core/stores/scroll_position_store.dart';
import 'package:mycelium/core/stores/user_store.dart';
import 'package:mycelium/data/local/api_preferences.dart';
import 'package:mycelium/data/local/collection_preferences.dart';
import 'package:mycelium/data/local/token_preferences.dart';
import 'package:mycelium/data/local/user_preferences.dart';
import 'package:mycelium/data/repositories/collection_repository.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/data/repositories/review_repository.dart';
import 'package:mycelium/data/repositories/user_repository.dart';
import 'package:mycelium/data/network/api_service.dart';
import 'package:mycelium/data/network/api_client.dart';
import 'package:mycelium/data/services/app_service.dart';
import 'package:mycelium/data/services/collection_service.dart';
import 'package:mycelium/data/services/node_service.dart';
import 'package:mycelium/data/services/review_service.dart';
import 'package:mycelium/data/services/user_service.dart';
import 'package:mycelium/domain/api_health_monitor.dart';
import 'package:mycelium/domain/app_coordinator.dart';
import 'package:mycelium/domain/check_app_update_usecase.dart';
import 'package:mycelium/domain/create_extract_usecase.dart';
import 'package:mycelium/domain/get_calendar_usecase.dart';
import 'package:mycelium/domain/get_outline_usecase.dart';
import 'package:mycelium/domain/init_api_usecase.dart';
import 'package:mycelium/domain/init_collections_usecase.dart';
import 'package:mycelium/domain/init_data_usecase.dart';
import 'package:mycelium/domain/init_user_usecase.dart';
import 'package:mycelium/domain/navigation_usecase.dart';
import 'package:mycelium/domain/node_usecase.dart';
import 'package:mycelium/domain/check_api_usecase.dart';
import 'package:mycelium/domain/refresh_current_node_usecase.dart';
import 'package:mycelium/domain/refresh_priorities_usecase.dart';
import 'package:mycelium/domain/remove_links_usecase.dart';
import 'package:mycelium/domain/reschedule_node_usecase.dart';
import 'package:mycelium/domain/review_node_usecase.dart';
import 'package:mycelium/domain/review_usecase.dart';
import 'package:mycelium/domain/transform_cloze_usecase.dart';
import 'package:mycelium/domain/select_collection_usecase.dart';
import 'package:mycelium/domain/select_user_usecase.dart';
import 'package:mycelium/domain/split_node_usecase.dart';
import 'package:mycelium/domain/update_api_usecase.dart';
import 'package:mycelium/domain/update_token_usecase.dart';
import 'package:mycelium/domain/update_priority_usecase.dart';
import 'package:mycelium/viewmodels/about_viewmodel.dart';
import 'package:mycelium/viewmodels/api_viewmodel.dart';
import 'package:mycelium/viewmodels/collections_viewmodel.dart';
import 'package:mycelium/viewmodels/deleted_nodes_viewmodel.dart';
import 'package:mycelium/viewmodels/home_viewmodel.dart';
import 'package:mycelium/viewmodels/launch_review_button_viewmodel.dart';
import 'package:mycelium/viewmodels/md_editor_viewmodel.dart';
import 'package:mycelium/viewmodels/settings_viewmodel.dart';

final sl = GetIt.instance;

Future<void> setup() async {
  sl.registerSingleton(NotificationBus());
  sl.registerSingleton(NetworkLogger());
  // Infra
  sl.registerSingleton(ApiPreferences());
  sl.registerSingleton(TokenPreferences());
  sl.registerSingleton(ApiStore());
  sl.registerSingleton(AppStore());
  sl.registerSingleton(ApiService(sl(), sl()));
  sl.registerSingleton(ApiClient(sl(), sl(), sl()));
  sl.registerSingleton(AppService());

  // Data
  sl.registerSingleton(UserPreferences());
  sl.registerSingleton(UserStore());
  sl.registerSingleton(UserService(sl()));
  sl.registerSingleton(UserRepository(sl()));
  sl.registerSingleton(CollectionPreferences());
  sl.registerSingleton(CollectionStore());
  sl.registerSingleton(CollectionService(sl()));
  sl.registerSingleton(CollectionRepository(sl()));
  sl.registerSingleton(NodeStore());
  sl.registerSingleton(NodeService(sl()));
  sl.registerSingleton(NodeRepository(sl()));
  sl.registerSingleton(ReviewStore());
  sl.registerSingleton(ReviewService(sl()));
  sl.registerSingleton(ReviewRepository(sl()));
  sl.registerSingleton(NavigationStore());
  sl.registerSingleton(ScrollPositionStore());

  // Editor
  sl.registerLazySingleton<EditorBackend>(() => InAppWebViewBackend());

  // Use cases/coords
  sl.registerSingleton(InitUserUseCase(sl(), sl(), sl(), sl()));
  sl.registerSingleton(SelectUserUseCase(sl(), sl()));
  sl.registerSingleton(CheckApiUseCase(sl(), sl(), sl(), sl()));
  sl.registerSingleton(UpdateApiUrlUseCase(sl(), sl(), sl()));
  sl.registerSingleton(UpdateTokenUseCase(sl(), sl()));
  sl.registerSingleton(InitCollectionsUseCase(sl(), sl(), sl(), sl()));
  sl.registerSingleton(
    InitDataUseCase(sl(), sl(), sl(), sl(), sl(), sl(), sl()),
  );
  sl.registerSingleton(InitApiUseCase(sl(), sl(), sl(), sl(), sl()));
  sl.registerSingleton(SelectCollectionUseCase(sl(), sl()));
  sl.registerSingleton(NavigationUseCase(sl(), sl(), sl(), sl()));
  sl.registerSingleton(RefreshPrioritiesUseCase(sl(), sl(), sl()));
  sl.registerSingleton(ReviewUseCase(sl(), sl(), sl(), sl(), sl(), sl()));
  sl.registerSingleton(TransformClozeUseCase(sl()));
  sl.registerSingleton(NodeUseCase(sl(), sl(), sl(), sl(), sl(), sl()));
  sl.registerSingleton(CheckAppUpdateUseCase(sl(), sl(), sl()));
  sl.registerSingleton(CreateExtractUseCase(sl(), sl(), sl(), sl(), sl()));
  sl.registerSingleton(GetCalendarUseCase(sl(), sl()));
  sl.registerSingleton(RescheduleNodeUseCase(sl(), sl(), sl()));
  sl.registerSingleton(ReviewNodeUseCase(sl(), sl()));
  sl.registerSingleton(RemoveLinksUseCase(sl(), sl(), sl()));
  sl.registerSingleton(UpdatePriorityUseCase(sl(), sl()));
  sl.registerSingleton(GetOutlineUseCase(sl(), sl()));
  sl.registerSingleton(SplitNodeUseCase(sl(), sl()));
  sl.registerSingleton(RefreshCurrentNodeUseCase(sl(), sl(), sl()));
  sl.registerSingleton(AppCoordinator(sl(), sl(), sl(), sl(), sl(), sl()));

  // Misc
  sl.registerSingleton(ApiHealthMonitor(sl(), sl(), sl()));

  // ViewModels
  sl.registerFactory(() => CollectionsViewModel(sl(), sl(), sl(), sl()));
  sl.registerFactory(() => AboutViewModel(sl(), sl()));
  //// should reduce dependencies ?
  sl.registerFactory(
    () => HomeViewModel(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );
  sl.registerFactory(() => ApiViewModel(sl(), sl(), sl(), sl(), sl(), sl()));
  //// should reduce dependencies ?
  sl.registerFactory(
    () => MdEditorViewModel(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );
  sl.registerFactory(() => LaunchReviewButtonViewmodel(sl()));
  sl.registerFactory(() => SettingViewModel(sl(), sl(), sl()));
  sl.registerFactory(() => DeletedNodesViewModel(sl(), sl(), sl(), sl(), sl()));
}
