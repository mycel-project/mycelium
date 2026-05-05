import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/data/local/api_preferences.dart';
import 'package:mycelium/domain/check_api_usecase.dart';

class UpdateApiUrlUseCase {
  final ApiStore apiStore;
  final ApiPreferences apiPreferences;
  final CheckApiUseCase checkApiUseCase;

  UpdateApiUrlUseCase(this.apiStore, this.apiPreferences, this.checkApiUseCase);

  Future<void> execute(String newUrl) async {
    if (newUrl == apiStore.baseUrl) return;
    await apiPreferences.saveBaseUrl(newUrl);
    apiStore.setBaseUrl(newUrl);
  }
}
