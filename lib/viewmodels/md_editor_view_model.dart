import 'package:flutter/material.dart';
import 'package:mycelium/data/models/node.dart';

class MdEditorViewModel extends ChangeNotifier {
  Node? node;

  String content = "";
  bool isDirty = false;

  void loadNode(Node node) {
    this.node = node;
    content = node.content?["0"]; 
    isDirty = false;
    notifyListeners();
  }

  void updateContent(String value) {
    content = value;
    isDirty = true;
    notifyListeners();
  }

  Future<void> save() async {
    isDirty = false;
    notifyListeners();
  }
}
