import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig extends ChangeNotifier {
  static const _key = "api_base_url";

  String _baseUrl = "";

  String get baseUrl => _baseUrl;

  AppConfig();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(_key) ?? "";
    notifyListeners();
  }

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, url);
  }
}
