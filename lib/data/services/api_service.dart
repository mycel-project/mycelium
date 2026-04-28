import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/data/api_result.dart';

class ApiService {
  final ApiStore apiStore;
  final Duration timeout;

  ApiService(this.apiStore, {this.timeout = const Duration(seconds: 5)});

  Uri _uri(String path) => Uri.parse("${apiStore.baseUrl}$path");

  Future<ApiResult<String>> get(String path) {
    return _request(() async {
      final response = await http.get(_uri(path)).timeout(timeout);

      return response;
    });
  }

  Future<ApiResult<String>> post(String path, Map<String, dynamic> body) {
    return _request(() async {
      final response = await http
          .post(
            _uri(path),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(timeout);

      return response;
    });
  }

  Future<ApiResult<String>> patch(String path, Map<String, dynamic> body) {
    return _request(() async {
      final response = await http
          .patch(
            _uri(path),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(timeout);

      return response;
    });
  }

  Future<ApiResult<String>> delete(String path) {
    return _request(() async {
      final response = await http.delete(_uri(path)).timeout(timeout);

      return response;
    });
  }

  Future<ApiResult<String>> _request(
    Future<http.Response> Function() call,
  ) async {
    try {
      final response = await call();

      apiStore.setReachable(true);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiSuccess(response.body);
      }

      dynamic body;
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = null;
      }

      final code = body is Map && body["detail"]["code"] != null
          ? body["detail"]["code"]
          : "http_error";

      final reason = body is Map
          ? body["detail"]["reason"] ?? response.body
          : response.body;

      return ApiError(code, statusCode: response.statusCode, message: reason);
    } on TimeoutException {
      apiStore.setReachable(false);
      return ApiError("timeout", statusCode: 408);
    } on SocketException {
      apiStore.setReachable(false);
      return ApiError("no_connection", statusCode: 503);
    } catch (e) {
      return ApiError("unknown", message: e.toString());
    }
  }

  Future<bool> checkReachability() async {
    final result = await get("/health");
    return result is ApiSuccess;
  }
}
