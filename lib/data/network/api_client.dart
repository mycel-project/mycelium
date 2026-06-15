import 'package:mycelium/core/notifications/notification_bus.dart';
import 'package:mycelium/data/network/api_service.dart';
import 'package:mycelium/data/api_result.dart';

class ApiClient {
  final ApiService _api;
  final NotificationBus _notificationBus;

  ApiClient(this._api, this._notificationBus);

  Future<ApiResult<String>> _guard(Future<ApiResult<String>> request) async {
    final result = await request;
    if (result is ApiError && result is! DomainError) {
      switch (result.type) {
        case "network":
          _notificationBus.showError(result.message ?? "network error", result);
        case "auth":
          String message = "Authentification error";
          String code = result.code;
          switch (code) {
            case "invalid_token":
              message =
                  "Your MycelCloud token is invalid. Please visit mycelcloud.com to generate a new one.";
            case "token_expired":
              message =
                  "Your MycelCloud token has expired. Please visit mycelcloud.com to generate a new one.";
            case "missing_token":
              message =
                  "No MycelCloud token configured. Please visit mycelcloud.com to get your token, then add it to your configuration.";
            case "not_subscribed":
              message =
                  "Your MycelCloud subscription is inactive. Please visit mycelcloud.com to update your subscription.";
            case "service_unavailable":
              message =
                  "MycelCloud is temporarily unavailable. Please try again in a few moments.";
          }
          _notificationBus.showError(message, result);
        case "version":
          _notificationBus.showError(
            result.message ?? "Incompatible version",
            result,
          );
        case "internal":
          _notificationBus.showError(
            "Internal error, report it at https://github.com/mycel-project/mycel.",
            result,
          );
        default:
          print(result.message);
          _notificationBus.showError(
            "Unknown error, report it at https://github.com/mycel-project/mycel.",
            result,
          );
      }
    }
    return result;
  }

  Future<ApiResult<String>> get(
    String path, {
    Map<String, String>? queryParams,
  }) => _guard(_api.get(path, queryParams: queryParams));

  Future<ApiResult<String>> post(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? queryParams,
  }) => _guard(_api.post(path, body, queryParams: queryParams));

  Future<ApiResult<String>> patch(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? queryParams,
  }) => _guard(_api.patch(path, body));

  Future<ApiResult<String>> delete(
    String path, {
    Map<String, String>? queryParams,
  }) => _guard(_api.delete(path));
}
