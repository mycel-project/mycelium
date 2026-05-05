import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/data/local/api_preferences.dart';
import 'package:mycelium/domain/check_api_usecase.dart';

class InitApiUseCase {
  final ApiStore apiStore;
  final CheckApiUseCase checkApiUseCase;
  final ApiPreferences apiPreferences;

  InitApiUseCase(this.apiStore, this.checkApiUseCase, this.apiPreferences);

  Future<bool> execute() async {
    final url = await apiPreferences.getBaseUrl() ?? "";
    apiStore.setBaseUrl(url);
    if (url.isEmpty) return false;
    return await checkApiUseCase.execute();
  }
}
