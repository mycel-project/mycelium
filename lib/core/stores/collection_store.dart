import 'package:flutter/material.dart';
import 'package:mycelium/data/models/collection.dart';

class CollectionStore extends ChangeNotifier {
  Collection? _currentCollection;
  Collection? get currentCollection => _currentCollection;

  void selectCollection(Collection collection) {
    _currentCollection = collection;
    notifyListeners();
  }

  void clearCollection() {
    _currentCollection = null;
    notifyListeners();
  }
}
