import 'package:flutter/material.dart';

/// ClaudeAI
class NavigationStore extends ChangeNotifier {
  final List<String> _history = [];
  int _cursor = -1;

  List<String> get history => List.unmodifiable(_history);
  String? get current => _cursor >= 0 ? _history[_cursor] : null;
  int get cursorIndex => _cursor;
  int get historyLength => _history.length;

  void push(String nodeId) {
    if (_cursor < _history.length - 1) {
      _history.removeRange(_cursor + 1, _history.length);
    }
    _history.add(nodeId);
    if (_history.length > 20) {
      _history.removeAt(0);
      _cursor = _history.length - 1;
    } else {
      _cursor = _history.length - 1;
    }
    notifyListeners();
  }

  String? idAtIndex(int index) {
    if (index < 0 || index >= _history.length) return null;
    return _history[index];
  }

  void moveCursorTo(int index) {
    assert(index >= 0 && index < _history.length);
    _cursor = index;
    notifyListeners();
  }

  void clear() {
    _history.clear();
    _cursor = -1;
    notifyListeners();
  }
  
  void truncateFrom(int index) {
    if (index < 0 || index > _history.length) return;
    _history.removeRange(index, _history.length);
    _cursor = _history.length - 1;
    notifyListeners();
  }

  void insertAt(int index, String nodeId) {
    final clampedIndex = index.clamp(0, _history.length);
    _history.insert(clampedIndex, nodeId);
    if (clampedIndex <= _cursor) {
      _cursor++;
    }
    if (_history.length > 20) {
      _history.removeAt(0);
      _cursor = (_cursor - 1).clamp(0, _history.length - 1);
    }
    notifyListeners();
  }
}
