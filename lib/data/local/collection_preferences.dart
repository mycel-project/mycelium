import 'package:shared_preferences/shared_preferences.dart';

class CollectionPreferences {
  static const _key = "selected_collection_id";

  Future<String?> getSavedId() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.get(_key);
    return value?.toString();
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
