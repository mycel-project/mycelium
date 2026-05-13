import 'package:flutter/cupertino.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/data/local/api_preferences.dart';
import 'package:mycelium/domain/api_status.dart';
import 'package:mycelium/domain/check_api_compatibility_usecase.dart';
import 'package:mycelium/domain/check_api_usecase.dart';

class InitApiUseCase {
  final ApiStore apiStore;
  final CheckApiUseCase checkApiUseCase;
  final ApiPreferences apiPreferences;
  final CheckApiCompatibilityUseCase checkApiCompatibilityUseCase;

  InitApiUseCase(
    this.apiStore,
    this.checkApiUseCase,
    this.apiPreferences,
    this.checkApiCompatibilityUseCase,
  );

  Future<ApiStatus> execute() async {
    final url = await apiPreferences.getBaseUrl() ?? "";

    if (url.isEmpty) {
      apiStore.setBaseUrl("");
      return ApiStatus.emptyUrl;
    }

    apiStore.setBaseUrl(url);

    await checkApiUseCase.execute();

    if (apiStore.apiStatus == ApiStatus.reachable) {
      final result = await checkApiCompatibilityUseCase.execute();
      debugPrint(result.toString());
    }

    return apiStore.apiStatus;
  }
}
