import 'package:flutter/material.dart';
import 'package:mycelium/core/either.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/collection.dart';
import 'package:mycelium/data/repositories/collection_repository.dart';
import 'package:mycelium/data/services/collection_service.dart';
import 'package:mycelium/domain/select_collection_usecase.dart';

class CollectionsViewModel extends ChangeNotifier {
  final CollectionService service; // To delete, use repo instead
  final CollectionStore collectionStore;
  final CollectionRepository collectionRepository;
  final SelectCollectionUseCase selectCollectionUseCase;

  List<Collection> collections = [];

  CollectionsViewModel(
    this.service,
    this.collectionStore,
    this.collectionRepository,
    this.selectCollectionUseCase,
  );

  Collection? get currentCollection => collectionStore.currentCollection;

  Future<void> selectCollection(Collection collection) async {
    await selectCollectionUseCase.execute(collection);
  }

  Future<void> loadCollections() async {
    collections = [];
    notifyListeners();
    final result = await collectionRepository.loadCollections();
    result.fold(
      (error) => print("Can't load collections: ${error.message}"),
      (data) {
        collections = data;
        notifyListeners();
      },
    );
  }

  Future<void> createCollection(String name) async {
    final result = await service.createCollection(name);

    if (result is ApiSuccess<Collection>) {
      collections.add(result.data);
    } else if (result is ApiError) {
      print("Can't create collection: ${result.code}");
    }

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
    if (candidates.isNotEmpty && currentCollection?.id != id) {
      collectionStore.selectCollection(candidates.first);
    }
  }
}
