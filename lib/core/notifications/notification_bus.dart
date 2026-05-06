import 'package:flutter/material.dart';
import 'package:mycelium/core/notifications/notification.dart';

class NotificationBus extends ChangeNotifier {
  MyceliumNotification? current;

  void show(String message, NotificationType type) {
    current = MyceliumNotification(message, type);
    notifyListeners();
  }

  void clear() {
    current = null;
    notifyListeners();
  }
}
