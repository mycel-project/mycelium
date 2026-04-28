import 'package:flutter/material.dart';
import 'package:mycelium/data/models/node.dart';

/// Currently selected node (may differ from the reviewed node if review mode is inactive or navigation occurs during review).
class NodeStore extends ChangeNotifier {
  Node? _currentNode;
  Node? get currentNode => _currentNode;

  void selectNode(Node? node) {
    _currentNode = node;
    notifyListeners();
  }
}
