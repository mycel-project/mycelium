import 'package:flutter/material.dart';
import 'package:mycelium/core/notifications/notification.dart';
import 'package:mycelium/data/api_result.dart';

class NotificationBus extends ChangeNotifier {
  final List<MyceliumNotification> _queue = [];

  void show(String description, NotificationType type, {String? title}) {
    _queue.add(MyceliumNotification(description, type, title: title));
    notifyListeners();
  }

  void showError(String message, [ApiError? error]) {
    _queue.add(
      MyceliumNotification(
        error != null ? "$message: ${error.code}" : message,
        NotificationType.error,
      ),
    );
    notifyListeners();
  }

  void showWarning(String message) {
    _queue.add(MyceliumNotification(message, NotificationType.warning));
    notifyListeners();
  }

  void showInfo(String message) {
    _queue.add(MyceliumNotification(message, NotificationType.info));
    notifyListeners();
  }

  void showSuccess(String message) {
    _queue.add(MyceliumNotification(message, NotificationType.success));
    notifyListeners();
  }

  List<MyceliumNotification> drainAll() {
    final pending = List<MyceliumNotification>.from(_queue);
    _queue.clear();
    return pending;
  }
}
