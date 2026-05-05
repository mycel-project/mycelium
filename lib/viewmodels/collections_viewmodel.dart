import 'package:flutter/material.dart';
import 'package:mycelium/core/either.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/data/models/collection.dart';
import 'package:mycelium/data/repositories/collection_repository.dart';
import 'package:mycelium/domain/select_collection_usecase.dart';

class CollectionsViewModel extends ChangeNotifier {
  final CollectionStore collectionStore;
  final CollectionRepository collectionRepository;
  final SelectCollectionUseCase selectCollectionUseCase;

  List<Collection> collections = [];

  CollectionsViewModel(
    this.collectionStore,
    this.collectionRepository,
    this.selectCollectionUseCase,
  );

  Collection? get currentCollection => collectionStore.currentCollection;

  Future<void> selectCollection(Collection collection) async {
    await selectCollectionUseCase.execute(collection);
  }

  Future<void> loadCollections() async {
    notifyListeners();
    final result = await collectionRepository.loadCollections();
    result.fold((error) => print("Can't load collections: ${error.message}"), (
        data,
      ) {
        collections = data;
        notifyListeners();
    });
  }

  Future<void> createCollection(String name) async {
    final result = await collectionRepository.createCollection(name);

    result.fold((error) => print("Can't create collection: ${error.message}"), (
        data,
      ) {
        collections.add(data);
        notifyListeners();
    });
  }

  Future<void> deleteCollection(int id) async {
    await collectionRepository.deleteCollection(id);
    collections.removeWhere((c) => c.id == id);
    if (collectionStore.currentCollection?.id == id) {
      collectionStore.clearCollection();
    }
    notifyListeners();
  }

  Future<void> renameCollection(int id, String newName) async {
    await collectionRepository.renameCollection(id, newName);
    final index = collections.indexWhere((c) => c.id == id);
    if (index != -1) {
      collections[index] = Collection(id: collections[index].id, name: newName);
    }
    notifyListeners();
  }

  void setCollection(int id) {
    final candidates = collections.where((c) => c.id == id);
    if (candidates.isNotEmpty && currentCollection?.id != id) {
      collectionStore.selectCollection(candidates.first);
    }
  }
}
