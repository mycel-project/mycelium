import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiViewModel extends ChangeNotifier {
  static const _key = "api_base_url";

  String url = "";

  Future<void> loadUrl() async {
    final prefs = await SharedPreferences.getInstance();
    url = prefs.getString(_key) ?? "";
  }

  Future<void> setUrl(String newUrl) async {
    url = newUrl;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, newUrl);
  }
}
