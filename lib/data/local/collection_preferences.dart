import 'package:shared_preferences/shared_preferences.dart';

class CollectionPreferences {
  static const _key = "selected_collection_id";

  Future<int?> getSavedId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key);
  }

  Future<void> saveId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, id);
  }

  Future<void> clearId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
