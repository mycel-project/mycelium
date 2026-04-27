import 'package:flutter/material.dart';
import 'package:mycelium/data/models/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollectionStore extends ChangeNotifier {
  static const _key = "selected_collection_id";

  Collection? _currentCollection;
  Collection? get currentCollection => _currentCollection;

  void selectCollection(Collection collection) {
    _currentCollection = collection;
    _saveId(collection.id);
    notifyListeners();
  }

  void clearCollection() {
    _currentCollection = null;
    _clearId();
    notifyListeners();
  }

  Future<int?> getSavedId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key);
  }

  Future<void> _saveId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, id);
  }

  Future<void> _clearId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
