import 'dart:convert';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/app_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/network/api_service.dart';
import 'package:mycelium/data/services/app_service.dart';
import 'package:mycelium/domain/connection_status.dart';
import 'package:mycelium/domain/compatibility_checker.dart';

class CheckApiResult {
  final ConnectionStatus status;
  final String? mycelVersion;
  final bool? compatible;

  CheckApiResult({
    required this.status,
    this.mycelVersion,
    this.compatible,
  });
}

class CheckApiUseCase {
  final ApiStore apiStore;
  final ApiService apiService;
  final AppStore appStore;
  final AppService appService;

  CheckApiUseCase(
    this.apiStore,
    this.apiService,
    this.appStore,
    this.appService,
  );

  Future<CheckApiResult> execute() async {
    final healthResult = await apiService.get("/health");
    switch (healthResult) {
      case ApiSuccess(:final data):
        try {
          final body = jsonDecode(data);
          if (body is! Map || body["status"] != "ok") {
            apiStore.setUnreachable();
            return CheckApiResult(status: ConnectionStatus.unreachable);
          }
        } catch (_) {
          apiStore.setUnreachable();
          return CheckApiResult(status: ConnectionStatus.unreachable);
        }
      case DomainError():
        break;
      case ApiError(:final type):
        switch (type) {
          case "network":
          case "invalid_response":
            apiStore.setUnreachable();
            return CheckApiResult(status: ConnectionStatus.unreachable);
          default:
            apiStore.setDegraded();
            return CheckApiResult(status: ConnectionStatus.degraded);
        }
    }

    apiStore.setConnected();

    try {
      final backendResult = await apiService.getVersion();
      if (backendResult is ApiError) {
        throw Exception("Backend version fetch failed");
      }

      final backendJson = jsonDecode((backendResult as ApiSuccess).data);
      final backendVersion = backendJson["version"];

      final compatibilityResponse = await appService.getCompatibilityMatrix();
      if (compatibilityResponse.statusCode != 200) {
        throw Exception("Cannot get compatibility matrix");
      }
      final compatibilityMatrix = jsonDecode(compatibilityResponse.body);

      final frontendVersion = appStore.version;
      final result = CompatibilityChecker().check(
        frontendVersion,
        backendVersion,
        compatibilityMatrix,
      );

      if (result == false) {
        apiStore.setDegraded();
        return CheckApiResult(
          status: ConnectionStatus.degraded,
          mycelVersion: backendVersion,
          compatible: false,
        );
      }

      return CheckApiResult(
        status: ConnectionStatus.connected,
        mycelVersion: backendVersion,
        compatible: result,
      );
    } catch (_) {
      return CheckApiResult(
        status: ConnectionStatus.connected,
        compatible: null,
      );
    }
  }
}
