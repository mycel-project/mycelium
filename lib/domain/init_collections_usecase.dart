import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/local/collection_preferences.dart';
import 'package:mycelium/data/models/collection.dart';
import 'package:mycelium/data/repositories/collection_repository.dart';

class InitCollectionsUseCase {
  final CollectionRepository collectionRepository;
  final CollectionStore collectionStore;
  final CollectionPreferences collectionPreferences;
  final NotificationBus notificationBus;

  InitCollectionsUseCase(
    this.collectionRepository,
    this.collectionStore,
    this.collectionPreferences,
    this.notificationBus,
  );

  Future<List<Collection>> execute() async {
    final savedId = await collectionPreferences.getSavedId();
    final result = await collectionRepository.loadCollections();

    switch (result) {
      case ApiSuccess(:final data):
        final collections = data;
        if (savedId != null && collections.isNotEmpty) {
          final match = collections.where((c) => c.id == savedId).firstOrNull;
          if (match != null) collectionStore.selectCollection(match);
        } else {
          print("No collection retrieved");
        }
        return collections;
      case DomainError error:
        notificationBus.showError("Cannot load collections", error);
        return [];
    }
    return [];
  }
}
