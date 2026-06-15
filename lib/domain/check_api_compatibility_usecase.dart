import 'dart:convert';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/app_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/network/api_service.dart';
import 'package:mycelium/data/services/app_service.dart';
import 'package:mycelium/domain/api_compatibility.dart';
import 'package:mycelium/domain/compatibility_checker.dart';

class CheckApiCompatibilityUseCase {
  final ApiStore apiStore;
  final ApiService apiService;
  final AppStore appStore;
  final AppService appService;

  CheckApiCompatibilityUseCase(
    this.apiStore,
    this.apiService,
    this.appStore,
    this.appService,
  );

  Future<ApiCompatibility> execute() async {
    apiStore.resetCompatibility();
    try {
      String frontendVersion = appStore.version;
      // if (frontendVersion == "dev") {
      //   frontendVersion = "0.0.1";
      // }

      final backendResult = await apiService.getVersion();
      if (backendResult is ApiError) {
        throw Exception("Backend version fetch failed");
      }

      final backendJson = jsonDecode((backendResult as ApiSuccess).data);
      final backendVersion = backendJson["version"];
      apiStore.version = backendVersion;

      final compatibilityResponse = await appService.getCompatibilityMatrix();

      if (compatibilityResponse.statusCode != 200) {
        throw Exception("Cannot get compatibility matrix");
      }
      final compatibilityMatrix = jsonDecode(compatibilityResponse.body);

      final result = CompatibilityChecker().check(
        frontendVersion,
        backendVersion,
        compatibilityMatrix,
      );

      apiStore.setCompatibility(result);
      return result;
    } catch (e, stackTrace) {
      print("CheckApiCompatibilityUseCase failed: $e");
      print("$stackTrace");
      apiStore.setCompatibilityError();
      return ApiCompatibility.error;
    }
  }
}
