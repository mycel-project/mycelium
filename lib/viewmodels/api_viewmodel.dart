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
    await checkReachability();
  }

  Future<void> checkReachability() async {
    isChecking = true;
    notifyListeners();
    final result = await apiService.checkReachability();
    apiStore.setReachable(result); 
    isChecking = false;
    notifyListeners();
  }
}
