import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/domain/check_api_usecase.dart';
import 'package:mycelium/domain/update_api_usecase.dart';

class ApiViewModel extends ChangeNotifier {
  final UpdateApiUrlUseCase updateApiUrlUseCase;
  final CheckApiUseCase checkApiUseCase;
  final ApiStore apiStore;
  bool isChecking = false;

  String get baseUrl => apiStore.baseUrl;

  ApiViewModel(this.updateApiUrlUseCase, this.checkApiUseCase, this.apiStore);

  Future<void> setUrl(String newUrl) async {
    await updateApiUrlUseCase.execute(newUrl);
    notifyListeners();
    checkReachability();
  }

  Future<void> checkReachability() async {
    isChecking = true;
    notifyListeners();
    await checkApiUseCase.execute();
    isChecking = false;
    notifyListeners();
  }
}
