import 'package:shared_preferences/shared_preferences.dart';

class ApiPreferences {
  static const _key = "api_base_url";

  Future<String?> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> saveBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, url);
  }
}
