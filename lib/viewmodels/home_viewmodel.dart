import 'package:flutter/material.dart';
import 'package:mycelium/ui/pages/api_config_page.dart';
import 'package:mycelium/ui/pages/collections_page.dart';

class HomeViewModel extends ChangeNotifier {
  void goToCollections(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CollectionsPage()),
    );
  }

  void goToApiConfig(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ApiConfigPage()),
    );
  }
}
