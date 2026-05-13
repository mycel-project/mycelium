import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/data/local/api_preferences.dart';
import 'package:mycelium/domain/api_status.dart';
import 'package:mycelium/domain/check_api_usecase.dart';

class InitApiUseCase {
  final ApiStore apiStore;
  final CheckApiUseCase checkApiUseCase;
  final ApiPreferences apiPreferences;

  InitApiUseCase(
    this.apiStore,
    this.checkApiUseCase,
    this.apiPreferences,
  );

  Future<ApiStatus> execute() async {
    final url = await apiPreferences.getBaseUrl() ?? "";

    if (url.isEmpty) {
      apiStore.setBaseUrl("");
      return ApiStatus.emptyUrl;
    }

    apiStore.setBaseUrl(url);

    await checkApiUseCase.execute();

    return apiStore.apiStatus;
  }
}
