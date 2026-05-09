import 'dart:convert';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/services/api_service.dart';

class ReviewService {
  final ApiService api;

  ReviewService(this.api);

  Future<ApiResult<String?>> getClozeRegex() async {
    final result = await api.get("/config/cloze-regex");

    if (result is ApiError) return result;

    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data) as Map<String, dynamic>;

    return ApiSuccess<String?>(json["regex"] as String?);
  }

  Future<ApiResult<String>> getNextReview(int colId) async {
    return await api.get("/collections/$colId/reviews/next");
  }

  Future<ApiResult<String>> undoReview(int colId) async {
    return await api.post("/collections/$colId/reviews/undo", {});
  }

  Future<ApiResult<String>> completeFragmentReview(
    int colId,
    int nodeId,
    int duration,
  ) async {
    return await api.post("/collections/$colId/nodes/$nodeId/fragment-review", {
      "duration": duration,
      "type_review_data": {},
    });
  }

  Future<ApiResult<String>> completeSporeReview(
    int colId,
    int nodeId,
    int duration,
    int rating,
  ) async {
    return await api.post("/collections/$colId/nodes/$nodeId/spore-review", {
      "duration": duration,
      "type_review_data": {"rating": rating},
    });
  }
}
