import 'package:flutter/material.dart';

class NetworkLogger extends ChangeNotifier {
  final List<NetworkLog> logs = [];

  void add(NetworkLog log) {
    logs.insert(0, log);
    if (logs.length > 100) logs.removeLast();
    notifyListeners();
  }

  void clear() {
    logs.clear();
    notifyListeners();
  }
}

class NetworkLog {
  final DateTime timestamp;
  final String method;
  final String url;
  final int? statusCode;
  final bool isError;
  final String? errorMessage;

  NetworkLog({
    required this.method,
    required this.url,
    this.statusCode,
    this.isError = false,
    this.errorMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
