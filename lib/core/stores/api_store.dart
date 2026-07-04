import 'package:flutter/material.dart';
import 'package:mycelium/domain/connection_status.dart';

class ApiStore extends ChangeNotifier {
  String _baseUrl = "https://api.mycelcloud.com";
  String _token = "";
  ConnectionStatus connectionStatus = ConnectionStatus.unknown;

  String get baseUrl => _baseUrl;
  String get token => _token;
  ConnectionStatus get status => connectionStatus;

  void setBaseUrl(String url) {
    _baseUrl = url;
    notifyListeners();
  }

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  void setConnected() {
    if (connectionStatus == ConnectionStatus.connected) return;
    connectionStatus = ConnectionStatus.connected;
    notifyListeners();
  }

  void setUnreachable() {
    if (connectionStatus == ConnectionStatus.unreachable) return;
    connectionStatus = ConnectionStatus.unreachable;
    notifyListeners();
  }

  void setDegraded() {
    if (connectionStatus == ConnectionStatus.degraded) return;
    connectionStatus = ConnectionStatus.degraded;
    notifyListeners();
  }

  void setUnknown() {
    if (connectionStatus == ConnectionStatus.unknown) return;
    connectionStatus = ConnectionStatus.unknown;
    notifyListeners();
  }
}
