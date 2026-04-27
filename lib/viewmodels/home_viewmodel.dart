import 'package:flutter/material.dart';
import 'package:mycelium/data/services/api_service.dart';
import 'package:mycelium/ui/pages/api_config_page.dart';
import 'package:mycelium/ui/pages/collections_page.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiService apiService;

  HomeViewModel({required this.apiService});

  void goToCollections(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CollectionsPage()),
    );
  }

  void goToApiConfig(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ApiConfigPage()));
  }

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
