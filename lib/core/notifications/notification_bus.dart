import 'package:flutter/material.dart';
import 'package:mycelium/core/notifications/notification.dart';
import 'package:mycelium/data/api_result.dart';

class NotificationBus extends ChangeNotifier {
  MyceliumNotification? current;

  void show(String title, NotificationType type, {String? details}) {
    current = MyceliumNotification(title, type, details: details);
    notifyListeners();
  }

  void showError(String message, ApiError error) {
    current = MyceliumNotification(
      "$message: ${error.code}",
      NotificationType.error,
      details: error.message,
    );
    notifyListeners();
  }

  void showWarning(String message, ApiError error) {
    current = MyceliumNotification(
      "$message: ${error.code}",
      NotificationType.warning,
      details: error.message,
    );
    notifyListeners();
  }

  void showInfo(String message) {
    current = MyceliumNotification(
      message,
      NotificationType.info,
    );
    notifyListeners();
  }

  void showSuccess(String message, ApiError error) {
    current = MyceliumNotification(
      "$message: ${error.code}",
      NotificationType.success,
      details: error.message,
    );
    notifyListeners();
  }

  void clear() {
    current = null;
    notifyListeners();
  }
}
