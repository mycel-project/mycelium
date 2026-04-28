import 'package:flutter/material.dart';
import 'package:mycelium/data/services/api_service.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiService apiService;

  HomeViewModel({required this.apiService});

  bool isCheckingConnection = false;
  Future<void> connectionStatusClick() async {
    // only ui state
    isCheckingConnection = true;
    notifyListeners();

    await Future.wait([
        apiService.checkReachability(),
        Future.delayed(const Duration(milliseconds: 500)),
    ]);

    isCheckingConnection = false;
    notifyListeners();
  }
}
