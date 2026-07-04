import 'dart:async';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/user_store.dart';
import 'package:mycelium/domain/check_api_usecase.dart';
import 'package:mycelium/domain/connection_status.dart';

class ApiHealthMonitor {
  final CheckApiUseCase checkApiUseCase;
  final ApiStore apiStore;
  final UserStore userStore;
  Timer? _timer;

  ApiHealthMonitor(this.checkApiUseCase, this.apiStore, this.userStore) {
    apiStore.addListener(_onApiStoreChanged);
    userStore.addListener(_onUserStoreChanged);
  }

  void _onApiStoreChanged() {
    if (apiStore.status == ConnectionStatus.unreachable) {
      _start();
    } else {
      _stop();
    }
  }

  void _onUserStoreChanged() {
    if (apiStore.status == ConnectionStatus.unreachable) {
      _stop();
      _start();
    }
  }

  void _start() {
    final intervalSeconds = userStore.conf?.get("ping_frequency") ?? 3;
    _timer ??= Timer.periodic(Duration(seconds: intervalSeconds), (_) {
      checkApiUseCase.execute();
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    _stop();
    apiStore.removeListener(_onApiStoreChanged);
  }
}
