import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static SharedPreferences? prefs;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    // await prefs?.clear();
    return;
  }

  static dynamic get(String key) {
    if (prefs == null) return;
    return prefs!.get(key);
  }

  static List<String>? getStringList(String key) {
    if (prefs == null) return null;
    return prefs!.getStringList(key);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    if (prefs == null) return;
    await prefs!.setStringList(key, value);
    return;
  }

  static set(String key, dynamic value) async {
    if (prefs == null) return;

    if (value is String) {
      await prefs!.setString(key, value);
    } else if (value is bool) {
      await prefs!.setBool(key, value);
    } else if (value is double) {
      await prefs!.setDouble(key, value);
    } else if (value is int) {
      await prefs!.setInt(key, value);
    } else if (value is List<String>) {
      await prefs!.setStringList(key, value);
    }

    return;
  }

  static clear() {
    prefs!.clear();
  }
}
