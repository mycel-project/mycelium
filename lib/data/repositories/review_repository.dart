import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/services/review_service.dart';

class ReviewRepository {
  final ReviewService reviewService;

  ReviewRepository(this.reviewService);

  Future<bool> reviewFragment(int colId, int nodeId, int duration) async {
    final result = await reviewService.completeFragmentReview(colId, nodeId, duration);
    
    if (result is ApiSuccess<List<void>>) {
      return true;
    }

    throw Exception("Failed to complete fragment review");
  }

  Future<bool> reviewSpore(int colId, int nodeId, int duration, int rating) async {
    final result = await reviewService.completeSporeReview(colId, nodeId, duration, rating);
    
    if (result is ApiSuccess<List<void>>) {
      return true;
    }

    throw Exception("Failed to complete spore review");
  }
}
