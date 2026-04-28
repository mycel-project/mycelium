import 'package:mycelium/core/stores/node_store.dart';
import 'package:mycelium/core/stores/review_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/services/review_service.dart';

class ReviewUseCase {
  final ReviewService reviewService;
  final NodeStore nodeStore;
  final ReviewStore reviewStore;

  ReviewUseCase(this.reviewService, this.nodeStore, this.reviewStore);

  Future<bool> handleNextReview(int colId) async {
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
