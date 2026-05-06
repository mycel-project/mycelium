enum NotificationType { error, info, success, warning }

class MyceliumNotification {
  final String title;
  final String? details;
  final NotificationType type;

  MyceliumNotification(this.title, this.type, {this.details});
}
