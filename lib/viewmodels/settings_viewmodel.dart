import 'package:flutter/material.dart';
import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/user_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/config_field/config_field.dart';
import 'package:mycelium/data/models/user.dart';
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
  Map<String, ConfigField> get schema => userRepository.configSchemaCache;

  Future<void> reloadSchema() async {
    userRepository.clearConfigSchemaCache();
    final result = await userRepository.getUserConfigSchema();
    if (result is ApiSuccess<Map<String, ConfigField>>) {
      notifyListeners();
    }
  }

  Future<void> updateConf(String key, dynamic value) async {
    final update = UserConfUpdate({key: value});
    final result = await userRepository.updateUserConfig(update);
    if (result is ApiSuccess<User>) {
      userStore.selectUser(result.data);
    } else if (result is ApiError) {
      notificationBus.showError("Cannot save settings", result);
      notifyListeners();
    }
  }
}
