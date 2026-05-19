import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/repositories/node_repository.dart';
import 'package:mycelium/data/repositories/review_repository.dart';

class ReviewNodeUseCase {
  final NodeRepository nodeRepository;
  final ReviewRepository reviewRepository;
  ReviewNodeUseCase(
    this.nodeRepository,
    this.reviewRepository
  );

  Future<ApiError?> execute(int colId, int nodeId, String type, {int? rating}) async {
    final result = switch (type) {
      "spore" => await reviewRepository.reviewSpore(colId, nodeId, 10, rating!),
      "fragment" => await reviewRepository.reviewFragment(colId, nodeId, 10),
      _ => throw ArgumentError("Unknown review type: $type"),
    };

    if (result case ApiError error) return error;

    if (result case ApiSuccess(:final data) when data != null) {
      nodeRepository.updateCache(data.id, data);
    }

    return null; 
  }
}
