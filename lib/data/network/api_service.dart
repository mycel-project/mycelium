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

  Uri _uri(String path, {Map<String, String>? queryParams}) => Uri.parse(
    "${apiStore.baseUrl}$path",
  ).replace(queryParameters: queryParams);

  Map<String, String> _buildHeader() {
    final token = apiStore.token;
    if (token == "" || token.isEmpty) {
      return {};
    }
    return {"authorization": "Bearer $token"};
  }

  Future<ApiResult<String>> get(
    String path, {
    Map<String, String>? queryParams,
  }) {
    return _request(
      () async => http
          .get(_uri(path, queryParams: queryParams), headers: _buildHeader())
          .timeout(timeout),
      method: "GET",
      url: path,
    );
  }

  Future<ApiResult<String>> post(
    String path,
    Map<String, dynamic>? body, {
    Map<String, String>? queryParams,
  }) {
    return _request(
      () async => http
          .post(
            _uri(path, queryParams: queryParams),
            headers: {..._buildHeader(), "Content-Type": "application/json"},
            body: body != null ? jsonEncode(body) : null,
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
            headers: {..._buildHeader(), "Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(timeout),
      method: "PATCH",
      url: path,
    );
  }

  Future<ApiResult<String>> delete(String path) {
    return _request(
      () async =>
          http.delete(_uri(path), headers: _buildHeader()).timeout(timeout),
      method: "DELETE",
      url: path,
    );
  }

  Future<ApiResult<String>> _request(
    Future<http.Response> Function() call, {
    required String method,
    required String url,
  }) async {
    http.Response response;
    try {
      response = await call();
    } on TimeoutException {
      networkLogger.add(
        NetworkLog(
          method: method,
          url: url,
          statusCode: 408,
          isError: true,
          errorMessage: "Timeout",
        ),
      );
      return ApiError("timeout", statusCode: 408, type: "network");
    } on SocketException {
      networkLogger.add(
        NetworkLog(
          method: method,
          url: url,
          statusCode: 503,
          isError: true,
          errorMessage: "No connection",
        ),
      );
      return ApiError("no_connection", statusCode: 503, type: "network");
    } catch (e) {
      networkLogger.add(
        NetworkLog(
          method: method,
          url: url,
          isError: true,
          errorMessage: e.toString(),
        ),
      );
      return ApiError("unknown", message: e.toString(), type: "network");
    }

    final isError = response.statusCode < 200 || response.statusCode >= 300;
    networkLogger.add(
      NetworkLog(
        method: method,
        url: url,
        statusCode: response.statusCode,
        isError: isError,
      ),
    );

    if (!isError) {
      try {
        jsonDecode(response.body);
      } catch (_) {
        return ApiError("invalid_response",
            statusCode: response.statusCode,
            message: "Response is not valid JSON",
            type: "invalid_response");
      }
      return ApiSuccess(response.body);
    }        
    String? errorType;
    String? errorCode;
    String? errorMessage;
    try {
      final body = jsonDecode(response.body);
      final detail = body["detail"];
      errorType = detail["type"];
      errorCode = detail["code"];
      errorMessage = detail["message"] ?? "";
    } catch (_) {
      errorCode = "http_error";
      errorMessage = response.body;
      errorType = "invalid_response";
    }

    if (errorType == "domain") {
      return DomainError(
        errorCode ?? "unknown_domain_error",
        statusCode: response.statusCode,
        message: errorMessage,
      );
    }

    return ApiError(
      errorCode ?? "http_error",
      statusCode: response.statusCode,
      message: errorMessage,
      type: errorType,
    );
  }
}
