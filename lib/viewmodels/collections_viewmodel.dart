import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/data/models/collection.dart';
import 'package:mycelium/data/services/collection_service.dart';

class CollectionsViewModel extends ChangeNotifier {
  final CollectionService service;
  final CollectionStore collectionStore;
  final ApiStore apiStore;

  List<Collection> collections = [];

  CollectionsViewModel(this.service, this.collectionStore, this.apiStore) {
    apiStore.addListener(_onApiChange);
  }

  void _onApiChange() {
    collectionStore.clearCollection();
    init();
  }
  Collection? get currentCollection => collectionStore.currentCollection;

  Future<void> init() async {
    collections = [];
    notifyListeners();
    collections = await service.getCollections();
    notifyListeners();
  }

  Future<void> createCollection(String name) async {
    final collection = await service.createCollection(name);
    collections.add(collection);
    notifyListeners();
  }

  Future<void> deleteCollection(int id) async {
    await service.deleteCollection(id);
    collections.removeWhere((c) => c.id == id);
    if (collectionStore.currentCollection?.id == id) {
      collectionStore.clearCollection();
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

  void setCollection(int id) {
    final candidates = collections.where((c) => c.id == id);
    if (candidates.isNotEmpty) collectionStore.selectCollection(candidates.first);
  }
}
