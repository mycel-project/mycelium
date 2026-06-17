import 'dart:convert';

import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/day_review_overview.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/services/review_service.dart';

class ReviewRepository {
  final ReviewService reviewService;

  ReviewRepository(this.reviewService);

  String? _clozeRegex;

  Future<ApiResult<Node?>> undoReview(String colId) async {
    final result = await reviewService.undoReview(colId);
    return parsedReviewData(result);
  }

  Future<ApiResult<Node?>> reviewFragment(
    String colId,
    String nodeId,
    int duration,
    int tzOffset,
    int slot,
  ) async {
    final result = await reviewService.completeFragmentReview(colId, nodeId, duration, tzOffset, slot);
    return parsedReviewData(result);
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
    return parsedReviewData(result);
  }

  Future<ApiResult<Map<DateTime, DayReviewOverview>>> getCalendar(
    String colId,
    int tzOffset
  ) async {
    final result = await reviewService.getCalendar(colId, tzOffset);
    if (result is ApiError) return result;

    final json = jsonDecode((result as ApiSuccess<String>).data)["data"];
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
    final json = jsonDecode((result as ApiSuccess<String>).data)["data"];
    final nodeJson = json["node"];
    if (nodeJson == null) return ApiSuccess(null);
    return ApiSuccess(Node.fromJson(nodeJson));
  }

  Future<ApiResult<Node?>> getNextReview(
    String colId,
    int tzOffset
  ) async {
    final result = await reviewService.getNextReview(colId, tzOffset);
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
