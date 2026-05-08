import 'package:get_it/get_it.dart';
import 'package:mycelium/core/debug/network_logger.dart';
import 'package:mycelium/core/notifications/notification_bus.dart';

import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/navigation_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/core/stores/user_store.dart';
import 'package:mycelium/data/local/api_preferences.dart';
import 'package:mycelium/data/local/collection_preferences.dart';
import 'package:mycelium/data/local/user_preferences.dart';
import 'package:mycelium/data/repositories/collection_repository.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/data/repositories/review_repository.dart';
import 'package:mycelium/data/repositories/user_repository.dart';
import 'package:mycelium/data/services/api_service.dart';
import 'package:mycelium/data/services/collection_service.dart';
import 'package:mycelium/data/services/node_service.dart';
import 'package:mycelium/data/services/review_service.dart';
import 'package:mycelium/data/services/user_service.dart';
import 'package:mycelium/domain/app_coordinator.dart';
import 'package:mycelium/domain/init_api_usecase.dart';
import 'package:mycelium/domain/init_collections_usecase.dart';
import 'package:mycelium/domain/init_data_usecase.dart';
import 'package:mycelium/domain/init_user_usecase.dart';
import 'package:mycelium/domain/navigation_usecase.dart';
import 'package:mycelium/domain/node_usecase.dart';
import 'package:mycelium/domain/check_api_usecase.dart';
import 'package:mycelium/domain/review_usecase.dart';
import 'package:mycelium/domain/select_collection_usecase.dart';
import 'package:mycelium/domain/select_user_usecase.dart';
import 'package:mycelium/domain/update_api_usecase.dart';
import 'package:mycelium/viewmodels/api_viewmodel.dart';
import 'package:mycelium/viewmodels/collections_viewmodel.dart';
import 'package:mycelium/viewmodels/home_viewmodel.dart';
import 'package:mycelium/viewmodels/launch_review_button_viewmodel.dart';
import 'package:mycelium/viewmodels/md_editor_view_model.dart';
import 'package:mycelium/viewmodels/settings_view_model.dart';

final sl = GetIt.instance;

Future<void> setup() async {
  sl.registerSingleton(NotificationBus());
  sl.registerSingleton(NetworkLogger());
  // Infra
  sl.registerSingleton(ApiPreferences());
  sl.registerSingleton(ApiStore());
  sl.registerSingleton(ApiService(sl(), sl()));

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

  // Use cases/coords
  sl.registerSingleton(InitUserUseCase(sl(), sl(), sl(), sl()));
  sl.registerSingleton(SelectUserUseCase(sl(), sl()));
  sl.registerSingleton(CheckApiUseCase(sl(), sl()));
  sl.registerSingleton(UpdateApiUrlUseCase(sl(), sl(), sl()));
  sl.registerSingleton(InitApiUseCase(sl(), sl(), sl()));
  sl.registerSingleton(InitCollectionsUseCase(sl(), sl(), sl(), sl()));
  sl.registerSingleton(SelectCollectionUseCase(sl(), sl()));
  sl.registerSingleton(NavigationUseCase(sl(), sl(), sl(), sl()));
  sl.registerSingleton(ReviewUseCase(sl(), sl(), sl(), sl(), sl()));
  sl.registerSingleton(NodeUseCase(sl(), sl(), sl(), sl(), sl()));
  sl.registerSingleton(InitDataUseCase(sl(), sl(), sl(), sl()));
  sl.registerSingleton(AppCoordinator(sl(), sl(), sl(), sl(), sl(), sl()));

  // ViewModels
  sl.registerFactory(() => CollectionsViewModel(sl(), sl(), sl(), sl()));
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
    ),
  );
  sl.registerFactory(() => ApiViewModel(sl(), sl(), sl(), sl()));
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
    ),
  );
  sl.registerFactory(() => LaunchReviewButtonViewmodel(sl()));
  sl.registerFactory(() => SettingViewModel(sl(), sl(), sl()));
  
}
