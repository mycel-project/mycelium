enum NotificationType { error, info, success, warning }

class MyceliumNotification {
  final String message;
  final NotificationType type;
  
  MyceliumNotification(this.message, this.type);
}
