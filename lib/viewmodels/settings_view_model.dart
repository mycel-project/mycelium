import 'package:flutter/material.dart';
import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/user_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/user_conf_update.dart';
import 'package:mycelium/data/repositories/user_repository.dart';
import 'package:mycelium/data/models/user_conf.dart';

class SettingViewModel extends ChangeNotifier {
  final UserStore userStore;
  final UserRepository userRepository;
  final NotificationBus notificationBus;

  SettingViewModel(this.userStore, this.userRepository, this.notificationBus) {
    userStore.addListener(notifyListeners);
  }

  UserConf? get conf => userStore.conf;

  Future<void> updateConf(UserConfUpdate update) async {
    final result = await userRepository.updateUserConfig(update);
    switch (result) {
      case ApiSuccess(:final data):
      userStore.selectUser(data);
      case ApiError error:
      notificationBus.showError("Cannot save settings", error);
    }
  }
}
