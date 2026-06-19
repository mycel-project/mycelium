enum NotificationType { error, info, success, warning }

class MyceliumNotification {
  final String? title;
  final String description;
  final NotificationType type;

  MyceliumNotification(this.description, this.type, {this.title});
}
