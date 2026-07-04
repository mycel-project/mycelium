import 'package:flutter/material.dart';
import 'package:mycelium/core/injection.dart';
import 'package:mycelium/core/notifications/notification.dart';
import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:toastification/toastification.dart';

class MyceliumNotificationListener extends StatefulWidget {
  final Widget child;

  const MyceliumNotificationListener({required this.child, super.key});

  @override
  State<MyceliumNotificationListener> createState() =>
      _MyceliumNotificationListenerState();
}

class _MyceliumNotificationListenerState
    extends State<MyceliumNotificationListener> {
  late final NotificationBus _bus;

  @override
  void initState() {
    super.initState();
    _bus = sl<NotificationBus>();
    _bus.addListener(_onNotification);
  }

  void _onNotification() {
    final notifications = _bus.drainAll();
    if (notifications.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      for (final notification in notifications) {
        try {
          toastification.show(
            context: context,
            style: ToastificationStyle.flatColored,
            type: switch (notification.type) {
              NotificationType.error => ToastificationType.error,
              NotificationType.success => ToastificationType.success,
              NotificationType.info => ToastificationType.info,
              NotificationType.warning => ToastificationType.warning,
            },
            title: notification.title != null
                ? Text(notification.title!)
                : null,
            description: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: SingleChildScrollView(
                child: Text(
                  notification.description,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            autoCloseDuration: const Duration(seconds: 4),
          );
        } catch (_) {
          // Prevents deadlock: if toastification.show() throws,
          // the queue is already drained so the system isn't stuck.
        }
      }
    });
  }

  @override
  void dispose() {
    _bus.removeListener(_onNotification);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
