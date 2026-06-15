import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/data/local/token_preferences.dart';

class UpdateTokenUseCase {
  final ApiStore apiStore;
  final TokenPreferences tokenPreferences;

  UpdateTokenUseCase(this.apiStore, this.tokenPreferences);

  Future<void> execute(String newToken) async {
    if (newToken == apiStore.token) return;
    await tokenPreferences.saveToken(newToken);
    apiStore.setToken(newToken);
  }
}
