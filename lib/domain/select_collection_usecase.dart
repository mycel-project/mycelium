import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/data/local/collection_preferences.dart';
import 'package:mycelium/data/models/collection.dart';

class SelectCollectionUseCase {
  final CollectionStore collectionStore;
  final CollectionPreferences collectionPreferences;

  SelectCollectionUseCase(this.collectionStore, this.collectionPreferences);

  Future<void> execute(Collection collection) async {
    collectionStore.selectCollection(collection);
    await collectionPreferences.saveId(collection.id);
  }
}
