import 'package:flutter/material.dart';

class ScrollPositionStore extends ChangeNotifier {
  int _offset = 0;
  int get offset => _offset;

  void update(int offset) {
    _offset = offset;
  }
}
