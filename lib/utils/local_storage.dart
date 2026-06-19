import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage._();

  static Future<bool> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  static Future<bool> saveJson(String key, Object value) async {
    return saveString(key, jsonEncode(value));
  }

  static Future<T?> getJson<T>(String key) async {
    final result = await getString(key);
    if (result == null) return null;
    final decoded = jsonDecode(result);
    return decoded as T;
  }
}
