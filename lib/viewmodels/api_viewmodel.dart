import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/data/services/api_service.dart';

class ApiViewModel extends ChangeNotifier {
  final ApiStore apiStore;
  final ApiService apiService;

  bool isChecking = false;

  ApiViewModel(this.apiStore, this.apiService);

  Future<void> setUrl(String newUrl) async {
    await apiStore.setBaseUrl(newUrl);
    final state = await checkReachability();
    apiStore.setReachable(state);
    notifyListeners();
  }

  Future<bool> checkReachability() async {
    isChecking = true;
    final result = await apiService.checkReachability();
    isChecking = false;
    return result;
  }
}
