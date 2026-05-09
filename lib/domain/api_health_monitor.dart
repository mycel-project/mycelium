import 'dart:async';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/domain/api_status.dart';
import 'package:mycelium/domain/check_api_usecase.dart';

class ApiHealthMonitor {
  final CheckApiUseCase checkApiUseCase;
  final ApiStore apiStore;
  Timer? _timer;

  ApiHealthMonitor(this.checkApiUseCase, this.apiStore) {
    apiStore.addListener(_onApiStoreChanged);
  }

  void _onApiStoreChanged() {
    if (apiStore.apiStatus == ApiStatus.unreachable) {
      _start();
    } else {
      _stop();
    }
  }

  void _start() {
    _timer ??= Timer.periodic(const Duration(seconds: 3), (_) {
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
