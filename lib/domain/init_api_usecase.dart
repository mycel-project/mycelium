import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/data/local/api_preferences.dart';
import 'package:mycelium/data/local/token_preferences.dart';
import 'package:mycelium/domain/api_status.dart';
import 'package:mycelium/domain/check_api_usecase.dart';
import 'package:mycelium/domain/init_data_usecase.dart';

class InitApiUseCase {
  final ApiStore apiStore;
  final CheckApiUseCase checkApiUseCase;
  final ApiPreferences apiPreferences;
  final InitDataUseCase initDataUseCase;
  final TokenPreferences tokenPreferences;

  InitApiUseCase(
    this.apiStore,
    this.checkApiUseCase,
    this.apiPreferences,
    this.initDataUseCase,
    this.tokenPreferences
  );

  Future<void> initApiUrl() async {
    final storedUrl = await apiPreferences.getBaseUrl();
    final token = await tokenPreferences.getToken();
    apiStore.setToken(token ?? "");

    final url = (storedUrl == null || storedUrl.isEmpty)
        ? "https://api.mycelcloud.com"
        : storedUrl;

    apiStore.setBaseUrl(url);
  }

  Future<void> execute() async {
    await initApiUrl();
    if (apiStore.baseUrl.isEmpty) return;
    await checkApiUseCase.execute();
    if (apiStore.status == ApiStatus.reachable) {
      await initDataUseCase.execute();
    }
  }
}
