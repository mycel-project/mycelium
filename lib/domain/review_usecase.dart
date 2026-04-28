import 'package:mycelium/core/stores/collection_store.dart';
import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/services/review_service.dart';

class ReviewUseCase {
  // Must pass trough review repository i guess
  final ReviewService reviewService;
  final NodeStore nodeStore;
  final ReviewStore reviewStore;
  final CollectionStore collectionStore;

  ReviewUseCase(
    this.reviewService,
    this.nodeStore,
    this.reviewStore,
    this.collectionStore,
  );

  Future<bool> handleNextReview() async {
    final colId = collectionStore.currentCollection?.id;
    if (colId == null) {
      throw StateError("No collection selected");
    }
    final result = await reviewService.getNextReview(colId);

    if (result is ApiSuccess<Node?>) {
      final node = result.data;

      if (node != null) {
        nodeStore.selectNode(node);
        reviewStore.setReview(node.id);
      } else {
        reviewStore.endReview();
      }
    } else if (result is ApiError) {
      print("Can't get next review: ${result.code}");
      return false;
    }

    return true;
  }
}
