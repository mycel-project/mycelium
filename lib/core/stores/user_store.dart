import 'package:flutter/material.dart';
import 'package:mycelium/data/models/user.dart';
import 'package:mycelium/data/models/user_conf.dart';


class UserStore extends ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;

  UserConf? get conf => _currentUser?.conf;

  void selectUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  void updateConf(UserConf conf) {
    if (_currentUser == null) return;
    _currentUser = User(
      id: _currentUser!.id,
      name: _currentUser!.name,
      createdAt: _currentUser!.createdAt,
      conf: conf,
    );
    notifyListeners();
  }
}
