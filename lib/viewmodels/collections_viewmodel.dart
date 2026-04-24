import 'package:flutter/material.dart';
import 'package:mycelium/data/models/collection.dart';
import 'package:mycelium/data/services/collection_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollectionsViewModel extends ChangeNotifier {
  static const _selectedKey = "selected_collection_id";

  final CollectionService service;

  Collection? selectedCollection;

  CollectionsViewModel(this.service);

  List<Collection> collections = [];

  Future<void> init() async {
    collections = await service.getCollections();

    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getInt(_selectedKey);

    if (savedId != null) {
      setCollection(savedId);
    }
  }

  Future<void> createCollection(String name) async {
    final collection = await service.createCollection(name);
    collections.add(collection);
    notifyListeners();
  }

  Future<void> deleteCollection(int id) async {
    await service.deleteCollection(id);
    collections.removeWhere((c) => c.id == id);
    if (selectedCollection?.id == id) {
      selectedCollection = null;
    }
    notifyListeners();
  }

  Future<void> renameCollection(int id, String newName) async {
    await service.renameCollection(id, newName);
    final index = collections.indexWhere((c) => c.id == id);
    if (index != -1) {
      collections[index] = Collection(id: collections[index].id, name: newName);
    }
    notifyListeners();
  }

  void setCollection(int id) async {
    selectedCollection = collections.firstWhere(
      (c) => c.id == id
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_selectedKey, id);

    notifyListeners();
  }
}
