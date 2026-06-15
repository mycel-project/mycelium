import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const _key = "selected_user_id";

  Future<String?> getSavedId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> saveId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, id);
  }

  Future<void> clearId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
