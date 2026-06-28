import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/data/local/api_preferences.dart';
import 'package:mycelium/domain/check_api_usecase.dart';

class UpdateApiUrlUseCase {
  final ApiStore apiStore;
  final ApiPreferences apiPreferences;
  final CheckApiUseCase checkApiUseCase;

  UpdateApiUrlUseCase(this.apiStore, this.apiPreferences, this.checkApiUseCase);

  Future<void> execute(String newUrl) async {
    String cleanedUrl = newUrl.trim();

    if (cleanedUrl.isNotEmpty) {
      // Remove all spaces, newlines, tabs, and invisible control/formatting characters
      cleanedUrl = cleanedUrl.replaceAll(
        RegExp(r'[\s\x00-\x1F\x7F\u200B-\u200D\uFEFF]'),
        '',
      );

      if (!cleanedUrl.startsWith('http://') &&
          !cleanedUrl.startsWith('https://')) {
        cleanedUrl = 'http://$cleanedUrl';
      }
      while (cleanedUrl.endsWith('/')) {
        cleanedUrl = cleanedUrl.substring(0, cleanedUrl.length - 1);
      }
    }

    if (cleanedUrl == apiStore.baseUrl) return;

    await apiPreferences.saveBaseUrl(cleanedUrl);
    apiStore.setBaseUrl(cleanedUrl);
  }
}
