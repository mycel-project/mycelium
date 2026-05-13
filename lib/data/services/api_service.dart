import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mycelium/core/debug/network_logger.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/data/api_result.dart';

class ApiService {
  final ApiStore apiStore;
  final NetworkLogger networkLogger;
  final Duration timeout;

  ApiService(
    this.apiStore,
    this.networkLogger, {
    this.timeout = const Duration(seconds: 5),
  });

  Uri _uri(String path) => Uri.parse("${apiStore.baseUrl}$path");

  Future<ApiResult<String>> get(String path) {
    return _request(
      () async => http.get(_uri(path)).timeout(timeout),
      method: "GET",
      url: path,
    );
  }

  Future<ApiResult<String>> post(String path, Map<String, dynamic> body) {
    return _request(
      () async => http
          .post(
            _uri(path),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(timeout),
      method: "POST",
      url: path,
    );
  }

  Future<ApiResult<String>> patch(String path, Map<String, dynamic> body) {
    return _request(
      () async => http
          .patch(
            _uri(path),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(timeout),
      method: "PATCH",
      url: path,
    );
  }

  Future<ApiResult<String>> delete(String path) {
    return _request(
      () async => http.delete(_uri(path)).timeout(timeout),
      method: "DELETE",
      url: path,
    );
  }

  Future<ApiResult<String>> _request(
    Future<http.Response> Function() call, {
    required String method,
    required String url,
  }) async {
    try {
      final response = await call();
      apiStore.setReachable();

      final isError = response.statusCode < 200 || response.statusCode >= 300;
      networkLogger.add(
        NetworkLog(
          method: method,
          url: url,
          statusCode: response.statusCode,
          isError: isError,
        ),
      );

      if (!isError) return ApiSuccess(response.body);

      dynamic body;
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = null;
      }
      final code = body is Map && body["code"] != null
          ? body["code"]
          : "http_error";
      final reason = body is Map
          ? body["message"] ?? response.body
          : response.body;
      return ApiError(code, statusCode: response.statusCode, message: reason);
    } on TimeoutException {
      apiStore.setUnreachable();
      networkLogger.add(
        NetworkLog(
          method: method,
          url: url,
          statusCode: 408,
          isError: true,
          errorMessage: "Timeout",
        ),
      );
      return ApiError("timeout", statusCode: 408);
    } on SocketException {
      apiStore.setUnreachable();
      networkLogger.add(
        NetworkLog(
          method: method,
          url: url,
          statusCode: 503,
          isError: true,
          errorMessage: "No connection",
        ),
      );
      return ApiError("no_connection", statusCode: 503);
    } catch (e) {
      networkLogger.add(
        NetworkLog(
          method: method,
          url: url,
          isError: true,
          errorMessage: e.toString(),
        ),
      );
      return ApiError("unknown", message: e.toString());
    }
  }

  Future<bool> checkReachability() async {
    final result = await get("/health");
    return result is ApiSuccess;
  }

  Future<ApiResult> getVersion() async {
    return await get("/version");
  }
}
