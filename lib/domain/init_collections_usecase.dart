import 'package:mycelium/core/either.dart';
import 'package:mycelium/core/errors/collection_errors.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/data/local/collection_preferences.dart';
import 'package:mycelium/data/models/collection.dart';
import 'package:mycelium/data/repositories/collection_repository.dart';

class InitCollectionsUseCase {
  final CollectionRepository collectionRepository;
  final CollectionStore collectionStore;
  final CollectionPreferences collectionPreferences;

  InitCollectionsUseCase(
    this.collectionRepository,
    this.collectionStore,
    this.collectionPreferences,
  );

  Future<Either<CollectionError, List<Collection>>> execute() async {
    final savedId = await collectionPreferences.getSavedId();
    final result = await collectionRepository.loadCollections();

    result.fold((error) => print("Can't load collections"), (collections) {
      if (savedId != null && collections.isNotEmpty) {
        final match = collections.where((c) => c.id == savedId).firstOrNull;
        if (match != null) collectionStore.selectCollection(match);
      } else {
        print("No collection retrieved");
      }
    });

    return result;
  }
}
