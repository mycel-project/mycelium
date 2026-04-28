import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/services/review_service.dart';

class ReviewRepository {
  final ReviewService reviewService;

  ReviewRepository(this.reviewService);

  String? _clozeRegex;

  Future<bool> reviewFragment(int colId, int nodeId, int duration) async {
    final result = await reviewService.completeFragmentReview(
      colId,
      nodeId,
      duration,
    );

    if (result is ApiError) {
      throw Exception(result.message ?? "Failed to complete fragment review");
    }

    return true;
  }

  Future<bool> reviewSpore(
    int colId,
    int nodeId,
    int duration,
    int rating,
  ) async {
    final result = await reviewService.completeSporeReview(
      colId,
      nodeId,
      duration,
      rating,
    );

    if (result is ApiError) {
      throw Exception(result.message ?? "Failed to complete spore review");
    }

    return true;
  }

  Future<String?> getClozeRegex() async {
    if (_clozeRegex != null) return _clozeRegex!;

    final result = await reviewService.getClozeRegex();

    if (result is ApiSuccess<String?>) {
      _clozeRegex = result.data;
      return result.data;
    }
    throw Exception("Failed to get ClozeRegex");
  }

  String? getClozeRegexSync() {
    return _clozeRegex;
  }
}
