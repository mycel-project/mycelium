import 'package:flutter/material.dart';
import 'package:mycelium/core/notifications/notification.dart';
import 'package:mycelium/data/api_result.dart';

class NotificationBus extends ChangeNotifier {
  MyceliumNotification? current;

  void show(String description, NotificationType type, {String? title}) {
    current = MyceliumNotification(description, type, title: title);
    notifyListeners();
  }

  void showError(String message, [ApiError? error]) {
    current = MyceliumNotification(
      error != null ? "$message: ${error.code}" : message,
      NotificationType.error,
    );
    notifyListeners();
  }

  void showWarning(String message) {
    current = MyceliumNotification(
      message,
      NotificationType.warning,
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

  void showSuccess(String message) {
    current = MyceliumNotification(
      message,
      NotificationType.success,
    );
    notifyListeners();
  }

  void clear() {
    current = null;
    notifyListeners();
  }
}
