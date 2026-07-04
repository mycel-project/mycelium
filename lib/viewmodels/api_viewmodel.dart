import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/app_store.dart';
import 'package:mycelium/domain/check_api_usecase.dart';
import 'package:mycelium/domain/connection_status.dart';
import 'package:mycelium/domain/init_data_usecase.dart';
import 'package:mycelium/domain/update_api_usecase.dart';
import 'package:mycelium/domain/update_token_usecase.dart';

class ApiViewModel extends ChangeNotifier {
  final UpdateApiUrlUseCase updateApiUrlUseCase;
  final UpdateTokenUseCase updateTokenUseCase;
  final CheckApiUseCase checkApiUseCase;
  final InitDataUseCase initDataUseCase;
  final ApiStore apiStore;
  final AppStore appStore;
  bool isChecking = false;
  int _checkGeneration = 0;

  String? _mycelVersion;
  bool? _compatible;

  String get baseUrl => apiStore.baseUrl;
  String get token => apiStore.token;
  String? get mycelVersion => _mycelVersion;
  bool? get mycelCompatible => _compatible;
  String get myceliumVersion => appStore.version;
  String errorMessage = "";

  ApiViewModel(
    this.updateApiUrlUseCase,
    this.updateTokenUseCase,
    this.checkApiUseCase,
    this.apiStore,
    this.initDataUseCase,
    this.appStore,
  );

  Future<void> setUrl(String newUrl) async {
    await updateApiUrlUseCase.execute(newUrl);
    notifyListeners();
    final status = await checkReachability();
    if (status == ConnectionStatus.connected) {
      initDataUseCase.execute();
    }
  }

  Future<void> setToken(String newToken) async {
    await updateTokenUseCase.execute(newToken);
    notifyListeners();
    final status = await checkReachability();
    if (status == ConnectionStatus.connected) {
      initDataUseCase.execute();
    }
  }

  Future<ConnectionStatus?> checkReachability() async {
    final gen = ++_checkGeneration;
    isChecking = true;
    notifyListeners();
    final result = await checkApiUseCase.execute();
    if (gen != _checkGeneration) return null;
    _mycelVersion = result.mycelVersion;
    _compatible = result.compatible;
    isChecking = false;
    notifyListeners();
    errorMessage = result.message ?? "";
    return result.status;
  }
}
