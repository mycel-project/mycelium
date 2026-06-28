import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/data/local/token_preferences.dart';

class UpdateTokenUseCase {
  final ApiStore apiStore;
  final TokenPreferences tokenPreferences;

  UpdateTokenUseCase(this.apiStore, this.tokenPreferences);

  Future<void> execute(String newToken) async {
    String cleanedToken = newToken.trim();
    if (cleanedToken.isNotEmpty) {
      cleanedToken = cleanedToken.replaceAll(
        RegExp(r'[\s\x00-\x1F\x7F\u200B-\u200D\uFEFF]'),
        '',
      );
    }

    if (cleanedToken == apiStore.token) return;
    await tokenPreferences.saveToken(cleanedToken);
    apiStore.setToken(cleanedToken);
  }
}
