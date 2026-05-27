import 'package:flutter/material.dart';

class ScrollPositionStore extends ChangeNotifier {
  int _offset = 0;
  int get offset => _offset;

  // When updating, pass a manual scroll instrution to md editor.
  void update(int offset) {
    _offset = offset;
    notifyListeners();
  }
}
