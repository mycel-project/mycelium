import 'package:flutter/material.dart';
import 'package:mycelium/core/notifications/notification.dart';
import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class MyceliumNotificationListener extends StatelessWidget {
  final Widget child;

  const MyceliumNotificationListener({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final bus = context.watch<NotificationBus>();
    final notification = bus.current;
    if (notification != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
          toastification.show(
            style: ToastificationStyle.minimal,
            type: switch (notification.type) {
              NotificationType.error => ToastificationType.error,
              NotificationType.success => ToastificationType.success,
              NotificationType.info => ToastificationType.info,
              NotificationType.warning => ToastificationType.warning,
            },
            title: notification.title != null ? Text(notification.title!) : null,
            description: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: SingleChildScrollView(
                child: Text(
                  notification.description,
                  style: TextStyle(
                    fontSize: 12
                  )
                ),
              ),
            ),
            autoCloseDuration: const Duration(seconds: 4),
          );
          bus.clear();
      });
    }
    return child;
  }
}
