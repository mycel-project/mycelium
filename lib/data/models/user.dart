import 'package:mycelium/data/models/user_conf.dart';

class User {
  const User({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.conf,
  });

  final int id;
  final String name;
  final int createdAt;
  final UserConf conf;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      createdAt: json['created_at'],
      conf: UserConf.fromJson(json['conf']),
    );
  }
}
