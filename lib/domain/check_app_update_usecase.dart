import 'dart:convert';
import 'package:pub_semver/pub_semver.dart';

import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/app_store.dart';
import 'package:mycelium/data/services/app_service.dart';

class CheckAppUpdateUseCase {
  final AppStore appStore;
  final NotificationBus notificationBus;
  final AppService appService;

  CheckAppUpdateUseCase(this.appStore, this.notificationBus, this.appService);

  Future<void> execute() async {
    try {
      String frontendVersion = appStore.version;

      if (frontendVersion == "dev") {
        return;
        //frontendVersion = "0.0.0";
      }

      final response = await appService.getLastAppVersion();

      if (response.statusCode == 403) {
        notificationBus.showWarning(
          "Cannot get new versions infos: GitHub API rate limit exceeded",
        );
        throw();
      }

      if (response.statusCode != 200) {
        throw Exception("Cannot get last version number");
      }

      final body = jsonDecode(response.body);

      appStore.lastVersionInfos = body;

      final tag = body["tag_name"] as String;
      final versionString = tag.startsWith('v') ? tag.substring(1) : tag;

      final currentVersion = Version.parse(frontendVersion);
      final latestVersion = Version.parse(versionString);

      if (latestVersion.major > currentVersion.major) {
        notificationBus.showSuccess(
          "A new major version of Mycelium is available (see ⋮ About)",
        );
      } else if (latestVersion.minor > currentVersion.minor) {
        notificationBus.showSuccess(
          "A new feature update is available : v$latestVersion (see ⋮ About)",
        );
      } else if (latestVersion.patch > currentVersion.patch) {
        notificationBus.showSuccess(
          "A new patch update is available : v$latestVersion (see ⋮ About)",
        );
      }
    } catch (e) {
      print("Cannot check last Mycelium update");
    }
  }
}
