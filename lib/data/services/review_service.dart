import 'dart:convert';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/models/node.dart';
import 'package:mycelium/data/services/api_service.dart';

class ReviewService {
  final ApiService api;

  ReviewService(this.api);

  Future<ApiResult<Node?>> getNextReview(int colId) async {
    final result = await api.get("/collections/$colId/next-review");

    if (result is ApiError) return result;

    final success = result as ApiSuccess<String>;
    final json = jsonDecode(success.data);

    final nodeJson = json["node_review"];

    if (nodeJson == null) {
      return ApiSuccess<Node?>(null);
    }

    return ApiSuccess<Node?>(
      Node.fromJson(nodeJson),
    );
  }
}
