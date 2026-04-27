import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiStore extends ChangeNotifier {
  static const _key = "api_base_url";
  
  String _baseUrl = "";
  bool? _isReachable;

  String get baseUrl => _baseUrl;
  bool? get isReachable => _isReachable;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(_key) ?? "";
    notifyListeners();
  }

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
    _isReachable = null; 
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, url);
  }

  void setReachable(bool value) {
    _isReachable = value;
    notifyListeners();
  }
}
