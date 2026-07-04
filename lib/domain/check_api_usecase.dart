import 'dart:convert';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/app_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/network/api_client.dart';
import 'package:mycelium/data/services/app_service.dart';
import 'package:mycelium/domain/connection_status.dart';
import 'package:mycelium/domain/compatibility_checker.dart';

class CheckApiResult {
  final ConnectionStatus status;
  final String? mycelVersion;
  final bool? compatible;
  final String? message;

  CheckApiResult({
    required this.status,
    this.mycelVersion,
    this.compatible,
    this.message,
  });
}

class CheckApiUseCase {
  final ApiStore apiStore;
  final ApiClient apiClient;
  final AppStore appStore;
  final AppService appService;

  CheckApiUseCase(
    this.apiStore,
    this.apiClient,
    this.appStore,
    this.appService,
  );

  Future<CheckApiResult> execute({bool silent = true}) async {
    final usedUrl = apiStore.baseUrl;
    final usedToken = apiStore.token;
    final healthResult = await apiClient.health(silent: silent);

    ConnectionStatus status = ConnectionStatus.unknown;
    String? message;
    String? mycelVersion;
    bool? compatible;

    switch (healthResult) {
      case ApiSuccess(:final data):
        try {
          final body = jsonDecode(data);
          if (body is! Map || body["status"] != "ok") {
            status = ConnectionStatus.unreachable;
            break;
          }
        } catch (_) {
          status = ConnectionStatus.unreachable;
          break;
        }
        status = ConnectionStatus.connected;

        try {
          final backendResult = await apiClient.version();
          if (backendResult is ApiError) {
            throw Exception("Backend version fetch failed");
          }

          final backendJson = jsonDecode((backendResult as ApiSuccess).data);
          final backendVersion = backendJson["version"];

          final compatibilityResponse = await appService
              .getCompatibilityMatrix();
          if (compatibilityResponse.statusCode != 200) {
            throw Exception("Cannot get compatibility matrix");
          }
          final compatibilityMatrix = jsonDecode(compatibilityResponse.body);

          final frontendVersion = appStore.version;
          final compatResult = CompatibilityChecker().check(
            frontendVersion,
            backendVersion,
            compatibilityMatrix,
          );

          mycelVersion = backendVersion;
          compatible = compatResult;

          if (compatResult == false) {
            status = ConnectionStatus.degraded;
          }
        } catch (_) {
          compatible = null;
        }

      case DomainError():
        status = ConnectionStatus.connected;

      case ApiError error:
        final errorType = error.type;
        switch (errorType) {
          case "network":
          case "invalid_response":
            status = ConnectionStatus.unreachable;
            message = usedUrl.isNotEmpty
                ? "No Mycel instance reachable at '$usedUrl'."
                : "Please entre a URL.";
          case "version":
          case "auth":
            status = ConnectionStatus.degraded;
            message = error.message;
          default:
            status = ConnectionStatus.degraded;
            message = error.message;
        }
    }

    if (usedUrl == apiStore.baseUrl && usedToken == apiStore.token) {
      switch (status) {
        case ConnectionStatus.connected:
          apiStore.setConnected();
        case ConnectionStatus.unreachable:
          apiStore.setUnreachable();
        case ConnectionStatus.degraded:
          apiStore.setDegraded();
        case ConnectionStatus.unknown:
          break;
      }
    }

    return CheckApiResult(
      status: status,
      message: message,
      mycelVersion: mycelVersion,
      compatible: compatible,
    );
  }
}
