import 'package:flutter/material.dart';
import 'package:mycelium/data/models/node.dart';

/// Currently selected node (may differ from the reviewed node if review mode is inactive or navigation occurs during review).
class NodeStore extends ChangeNotifier {
  Node? _currentNode;
  Node? _previousNode;
  
  Node? get currentNode => _currentNode;
  Node? get previousNode => _previousNode;

  void selectNode(Node? node) {
    _previousNode = _currentNode;
    _currentNode = node;
    notifyListeners();
  }
}
