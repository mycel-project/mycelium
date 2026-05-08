import 'package:mycelium/core/notifications/notification.dart';
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

  Future<List<User>> execute() async {
    final savedId = await userPreferences.getSavedId();
    final result = await userRepository
        .getCurrentUser(); // Must change to fetch multiple users potentially

    switch (result) {
      case ApiSuccess(:final data):
        final users = [
          data,
        ]; // force conversion to list, remove when getchnig liset of users directly
        if (users.isEmpty) {
          notificationBus.show(
            "Default user has not been automatically created in Mycel as users is empty",
            NotificationType.error,
          );
        }
        if (savedId != null && users.isNotEmpty) {
          final match = users.where((u) => u.id == savedId).firstOrNull;
          if (match != null) userStore.selectUser(match);
        } else {
          //    print("No user retrieved");  // Normally juste toast that or do nothing, but for now with only one user we will force selection to default
          try {
            final defaultUser = users.firstWhere((u) => u.id == 1);
            userStore.selectUser(defaultUser);
          } catch (_) {
            notificationBus.show(
              "Default user with id 1 has not been automatically created in Mycel",
              NotificationType.error,
            );
          }
        }
        return users;
      case ApiError error:
        notificationBus.showError("Cannot load user", error);
        return [];
    }
  }
}
