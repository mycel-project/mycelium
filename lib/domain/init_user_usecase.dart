import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/user_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/local/user_preferences.dart';
import 'package:mycelium/data/repositories/user_repository.dart';
import 'package:mycelium/data/models/user.dart';

class InitUserUseCase {
  final UserStore userStore;
  final UserRepository userRepository;
  final UserPreferences userPreferences;
  final NotificationBus notificationBus;

  InitUserUseCase(
    this.userStore,
    this.userRepository,
    this.userPreferences,
    this.notificationBus,
  );

  Future<User?> execute() async {
    //final savedId = await userPreferences.getSavedId(); // not using mutliple user for now
    final result = await userRepository.getCurrentUser(); // Must change to fetch multiple users potentially

    switch (result) {
      case ApiSuccess(:final data):
        final user = data;
        userStore.selectUser(user);
        return user;
      case DomainError error:
        notificationBus.showError("Cannot load user", error);
    }
    return null;
  }
}
