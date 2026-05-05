import 'package:flutter/material.dart';

class ApiStore extends ChangeNotifier {
  String _baseUrl = "";
  bool? _isReachable;

  String get baseUrl => _baseUrl;
  bool? get isReachable => _isReachable;

  void setBaseUrl(String url) {
    _baseUrl = url;
    _isReachable = null;
    notifyListeners();
  }

  void setReachable(bool value) {
    if (_isReachable == value) return;
    _isReachable = value;
    notifyListeners();
  }
}
