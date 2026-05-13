import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/core/stores/app_store.dart';
import 'package:mycelium/data/api_result.dart';
import 'package:mycelium/data/services/api_service.dart';
import 'package:mycelium/domain/api_compatibility.dart';
import 'package:mycelium/domain/compatibility_checker.dart';

class CheckApiCompatibilityUseCase {
  final ApiStore apiStore;
  final ApiService apiService;
  final AppStore appStore;

  CheckApiCompatibilityUseCase(this.apiStore, this.apiService, this.appStore);

  Future<ApiCompatibility> execute() async {
    apiStore.resetCompatibility();
    try {
      final frontendVersion = appStore.version;

      final backendResult = await apiService.getVersion();
      if (backendResult is ApiError) {
        throw Exception("Backend version fetch failed");
      }

      final backendJson = jsonDecode((backendResult as ApiSuccess).data);
      final backendVersion = backendJson["version"];

      final compatibilityResponse = await http.get(
        // query param to avoid caching
        Uri.parse(
          "https://raw.githubusercontent.com/mycel-project/mycelium/main/compatibility.json?ts=${DateTime.now().millisecondsSinceEpoch}",
        ),
      );
      if (compatibilityResponse.statusCode != 200) {
        apiStore.setCompatibilityError();
        return ApiCompatibility.error;
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
