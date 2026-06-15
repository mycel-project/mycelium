import 'package:flutter/material.dart';
import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/collection.dart';
import 'package:mycelium/data/repositories/collection_repository.dart';
import 'package:mycelium/domain/select_collection_usecase.dart';

class CollectionsViewModel extends ChangeNotifier {
  final CollectionStore collectionStore;
  final CollectionRepository collectionRepository;
  final SelectCollectionUseCase selectCollectionUseCase;
  final NotificationBus notificationBus;

  CollectionsViewModel(
    this.collectionStore,
    this.collectionRepository,
    this.selectCollectionUseCase,
    this.notificationBus,
  );

  Collection? get currentCollection => collectionStore.currentCollection;

  Future<void> reloadIfEmpty() async {
    if (collections.isEmpty) {
      await loadCollections();
    }
  }

  List<Collection> get collections =>
      collectionRepository.collectionCache.values.toList();

  Future<void> loadCollections() async {
    final result = await collectionRepository.loadCollections();

    switch (result) {
      case ApiSuccess():
        notifyListeners();
      case DomainError error:
        notificationBus.showError("Cannot load collections", error);
    }
  }

  Future<bool> createCollection(String? name) async {
    if (name == null || name.isEmpty) {
      notificationBus.showWarning("Empty name");
      return false;
    }
    final result = await collectionRepository.createCollection(name);

    switch (result) {
      case ApiSuccess():
        notifyListeners();
        return true;
      case DomainError error:
        notificationBus.showError("Cannot create collection", error);
    }
    return false;
  }

  Future<void> deleteCollection(int id) async {
    await collectionRepository.deleteCollection(id);
    if (collectionStore.currentCollection?.id == id) {
      collectionStore.clearCollection();
    }
    notifyListeners();
  }

  Future<bool> renameCollection(int id, String? newName) async {
    if (newName == null || newName.isEmpty) {
      notificationBus.showWarning("Empty name");
      return false;
    }
    final result = await collectionRepository.renameCollection(id, newName);

    switch (result) {
      case ApiSuccess():
        notifyListeners();
        return true;
      case DomainError error:
        notificationBus.showError("Cannot rename collection", error);
    }
    return false;
  }

  Future<void> setCollection(int id) async {
    final candidates = collections.where((c) => c.id == id);
    if (candidates.isNotEmpty && currentCollection?.id != id) {
      await selectCollectionUseCase.execute(candidates.first);
    }
  }
}
