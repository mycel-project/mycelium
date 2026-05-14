import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/data/local/api_preferences.dart';
import 'package:mycelium/domain/api_status.dart';
import 'package:mycelium/domain/check_api_usecase.dart';
import 'package:mycelium/domain/init_data_usecase.dart';

class InitApiUseCase {
  final ApiStore apiStore;
  final CheckApiUseCase checkApiUseCase;
  final ApiPreferences apiPreferences;
  final InitDataUseCase initDataUseCase;

  InitApiUseCase(
    this.apiStore,
    this.checkApiUseCase,
    this.apiPreferences,
    this.initDataUseCase,
  );

  Future<void> initApiUrl() async {
    final url = await apiPreferences.getBaseUrl() ?? "";
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
