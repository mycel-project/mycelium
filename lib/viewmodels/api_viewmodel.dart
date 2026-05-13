import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/app_store.dart';
import 'package:mycelium/domain/api_compatibility.dart';
import 'package:mycelium/domain/api_status.dart';
import 'package:mycelium/domain/check_api_usecase.dart';
import 'package:mycelium/domain/init_data_usecase.dart';
import 'package:mycelium/domain/update_api_usecase.dart';

class ApiViewModel extends ChangeNotifier {
  final UpdateApiUrlUseCase updateApiUrlUseCase;
  final CheckApiUseCase checkApiUseCase;
  final InitDataUseCase initDataUseCase;
  final ApiStore apiStore;
  final AppStore appStore;
  bool isChecking = false;

  String get baseUrl => apiStore.baseUrl;
  String? get mycelVersion => apiStore.version;
  ApiCompatibility get mycelCompatibility => apiStore.compatibility;
  String get myceliumVersion => appStore.version;

  ApiViewModel(
    this.updateApiUrlUseCase,
    this.checkApiUseCase,
    this.apiStore,
    this.initDataUseCase,
    this.appStore,
  );

  Future<void> setUrl(String newUrl) async {
    await updateApiUrlUseCase.execute(newUrl);
    notifyListeners();
    final status = await checkReachability();
    if (status == ApiStatus.reachable) {
      initDataUseCase.execute();
    }
  }

  Future<ApiStatus> checkReachability() async {
    isChecking = true;
    notifyListeners();
    final status = await checkApiUseCase.execute();
    isChecking = false;
    notifyListeners();
    return status;
  }
}
