import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/domain/review_usecase.dart';

class LaunchReviewButtonViewmodel extends ChangeNotifier {
  final ReviewUseCase reviewUseCase;
  final CollectionStore collectionStore;
  LaunchReviewButtonViewmodel(this.reviewUseCase, this.collectionStore);

  void launch() {
    final colId = collectionStore.currentCollection?.id;
    if (colId != null) {
      reviewUseCase.handleNextReview(colId);
    } else {
      throw StateError("No collection selected");
    }
  }
}
