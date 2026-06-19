import 'dart:convert';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/network/api_client.dart';

class ReviewService {
  final ApiClient api;

  ReviewService(this.api);

  Future<ApiResult<String?>> getClozeRegex() async {
    final result = await api.get("/constants/cloze-regex");

    if (result is ApiError) return result;

    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data) as Map<String, dynamic>;

    return ApiSuccess<String?>(json["regex"] as String?);
  }

  Future<ApiResult<String>> getNextReview(String colId, int tzOffset) async {
    return await api.get(
      "/collections/$colId/reviews/next",
      queryParams: {
        "tz_offset": tzOffset.toString()
      },
    );
  }

  Future<ApiResult<String>> getCalendar(String colId, int tzOffset) async {
    return await api.get(
      "/collections/$colId/reviews/calendar",
      queryParams: {
        "tz_offset": tzOffset.toString()
      },
    );
  }

  Future<ApiResult<String>> undoReview(String colId) async {
    return await api.post("/collections/$colId/reviews/undo", null);
  }

  Future<ApiResult<String>> completeFragmentReview(
    String colId,
    String nodeId,
    int duration,
    int tzOffset,
    int slot,
  ) async {
    return await api.post("/collections/$colId/nodes/$nodeId/review", {
      "duration": duration,
      "type_review_data": {"type": "fragment"},
      "tz_offset": tzOffset,
      "slot": slot,
    });
  }

  Future<ApiResult<String>> completeSporeReview(
    String colId,
    String nodeId,
    int duration,
    int rating,
    int tzOffset,
    int slot,
  ) async {
    return await api.post("/collections/$colId/nodes/$nodeId/review", {
      "duration": duration,
      "type_review_data": {"type": "spore", "rating": rating},
      "tz_offset": tzOffset,
      "slot": slot,
    });
  }
}
