import 'dart:convert';

import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/day_review_overview.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/models/review_target.dart';
import 'package:mycelium/data/services/review_service.dart';

class ReviewRepository {
  final ReviewService reviewService;

  ReviewRepository(this.reviewService);

  String? _clozeRegex;

  Future<ApiResult<ReviewTarget?>> undoReview(String colId) async {
    final result = await reviewService.undoReview(colId);
    return parseReviewData(result);
  }

  Future<ApiResult<Node?>> reviewFragment(
    String colId,
    String nodeId,
    int duration,
    int tzOffset,
    int slot,
  ) async {
    final result = await reviewService.completeFragmentReview(
      colId,
      nodeId,
      duration,
      tzOffset,
      slot,
    );
    return parseNodeData(result);
  }

  Future<ApiResult<Node?>> reviewSpore(
    String colId,
    String nodeId,
    int duration,
    int rating,
    int tzOffset,
    int slot,
  ) async {
    final result = await reviewService.completeSporeReview(
      colId,
      nodeId,
      duration,
      rating,
      tzOffset,
      slot,
    );
    return parseNodeData(result);
  }

  Future<ApiResult<Map<DateTime, DayReviewOverview>>> getCalendar(
    String colId,
    int tzOffset,
  ) async {
    final result = await reviewService.getCalendar(colId, tzOffset);
    if (result is ApiError) return result;

    final json = jsonDecode((result as ApiSuccess<String>).data)["data"];
    final calendar = json as List;

    final list = calendar.map((e) => DayReviewOverview.fromJson(e)).toList();

    final map = {for (final item in list) DateTime.parse(item.date): item};

    return ApiSuccess(map);
  }

  ApiResult<Node?> parseNodeData(ApiResult<String> result) {
    if (result is ApiError) return result;
    final json = jsonDecode((result as ApiSuccess<String>).data)["data"];
    final nodeJson = json;
    if (nodeJson == null) return ApiSuccess(null);
    return ApiSuccess(Node.fromJson(nodeJson));
  }

  ApiResult<ReviewTarget?> parseReviewData(ApiResult<String> result) {
    if (result is ApiError) return result;
    final json = jsonDecode((result as ApiSuccess<String>).data)["data"];
    if (json == null) return ApiSuccess(null);
    return ApiSuccess(ReviewTarget.fromJson(json));
  }

  Future<ApiResult<ReviewTarget?>> getNextReview(
    String colId,
    int tzOffset,
  ) async {
    final result = await reviewService.getNextReview(colId, tzOffset);
    return parseReviewData(result);
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

  void clearClozeRegex() {
    _clozeRegex = null;
  }
}
