import 'package:shared_preferences/shared_preferences.dart';

class TokenPreferences {
  static const _key = "mycelcloud_token";

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }
}
