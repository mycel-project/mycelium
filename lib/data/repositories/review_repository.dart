import 'dart:convert';

import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/day_review_overview.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/services/review_service.dart';

class ReviewRepository {
  final ReviewService reviewService;

  ReviewRepository(this.reviewService);

  String? _clozeRegex;

  Future<ApiResult<Node?>> undoReview(int colId) async {
    final result = await reviewService.undoReview(colId);
    return parsedReviewData(result);
  }

  Future<ApiResult<void>> reviewFragment(
    int colId,
    int nodeId,
    int duration,
  ) async {
    return await reviewService.completeFragmentReview(colId, nodeId, duration);
  }

  Future<ApiResult<void>> reviewSpore(
    int colId,
    int nodeId,
    int duration,
    int rating,
  ) async {
    return await reviewService.completeSporeReview(
      colId,
      nodeId,
      duration,
      rating,
    );
  }

  Future<ApiResult<Map<DateTime, DayReviewOverview>>> getCalendar(
    int colId,
  ) async {
    final result = await reviewService.getCalendar(colId);
    if (result is ApiError) return result;

    final json = jsonDecode((result as ApiSuccess<String>).data);
    final calendar = json["calendar"] as List;

    final list = calendar
    .map((e) => DayReviewOverview.fromJson(e))
    .toList();

    final map = {
      for (final item in list) DateTime.parse(item.date): item,
    };

    return ApiSuccess(map);
  }

  ApiResult<Node?> parsedReviewData(ApiResult<String> result) {
    if (result is ApiError) return result;
    final json = jsonDecode((result as ApiSuccess<String>).data);
    final nodeJson = json["node_review"];
    if (nodeJson == null) return ApiSuccess(null);
    return ApiSuccess(Node.fromJson(nodeJson));
  }

  Future<ApiResult<Node?>> getNextReview(int colId) async {
    final result = await reviewService.getNextReview(colId);
    return parsedReviewData(result);
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
