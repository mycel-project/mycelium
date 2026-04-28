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
    final result = await api.get("/collections/$colId/next-review");

    if (result is ApiError) return result;

    final success = result as ApiSuccess<String>;

    return ApiSuccess<String>(success.data);
  }

  Future<ApiResult<String>> completeFragmentReview(
    int colId,
    int nodeId,
    int duration,
  ) async {
    final result = await api.post(
      "/collections/$colId/nodes/$nodeId/fragment-review",
      {"duration": duration},
    );

    if (result is ApiError) return result;

    final success = result as ApiSuccess<String>;

    return ApiSuccess<String>(success.data);
  }

  Future<ApiResult<String>> completeSporeReview(
    int colId,
    int nodeId,
    int duration,
    int rating,
  ) async {
    final result = await api.post(
      "/collections/$colId/nodes/$nodeId/spore-review",
      {
        "rating": rating,
        "duration": duration,
      },
    );

    if (result is ApiError) return result;

    final success = result as ApiSuccess<String>;

    return ApiSuccess<String>(success.data);
  }
}
