import 'package:flutter/material.dart';
import 'package:mycelium/data/models/node.dart';

class NodeStore extends ChangeNotifier {
  Node? _currentNode;
  Node? get currentNode => _currentNode;

  void selectNode(Node? node) {
    _currentNode = node;
    notifyListeners();
  }
}
