import 'package:flutter/material.dart';


/// ClaudeAI
class NavigationStore extends ChangeNotifier {
  final List<int> _history = [];
  int _cursor = -1;

  List<int> get history => List.unmodifiable(_history);
  int? get current => _cursor >= 0 ? _history[_cursor] : null;
  bool get canGoBack => _cursor > 0;
  bool get canGoForward => _cursor < _history.length - 1;

  void push(int nodeId) {
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

  int? back() {
    if (!canGoBack) return null;
    _cursor--;
    notifyListeners();
    return _history[_cursor];
  }

  int? forward() {
    if (!canGoForward) return null;
    _cursor++;
    notifyListeners();
    return _history[_cursor];
  }

  void clear() {
    _history.clear();
    _cursor = -1;
    notifyListeners();
  }
}
