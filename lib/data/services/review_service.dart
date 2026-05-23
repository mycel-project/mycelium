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

  Future<ApiResult<String>> getNextReview(int colId, int tzOffset) async {
    return await api.get(
      "/collections/$colId/reviews/next",
      queryParams: {
        "tz_offset": tzOffset.toString()
      },
    );
  }

  Future<ApiResult<String>> getCalendar(int colId, int tzOffset) async {
    return await api.get(
      "/collections/$colId/reviews/calendar",
      queryParams: {
        "tz_offset": tzOffset.toString()
      },
    );
  }

  Future<ApiResult<String>> undoReview(int colId) async {
    return await api.post("/collections/$colId/reviews/undo", {});
  }

  Future<ApiResult<String>> completeFragmentReview(
    int colId,
    int nodeId,
    int duration,
    int tzOffset
  ) async {
    return await api.post("/collections/$colId/nodes/$nodeId/fragment-review", {
      "duration": duration,
      "type_review_data": {},
      "tz_offset": tzOffset.toString(),
    });
  }

  Future<ApiResult<String>> completeSporeReview(
    int colId,
    int nodeId,
    int duration,
    int rating,
    int tzOffset
  ) async {
    return await api.post("/collections/$colId/nodes/$nodeId/spore-review", {
      "duration": duration,
      "type_review_data": {"rating": rating},
      "tz_offset": tzOffset.toString(),
    });
  }
}
