import 'package:shared_preferences/shared_preferences.dart';

import 'secure_storage_interface.dart';

class WebSecureStorage implements ISecureStorage {
  static const WebSecureStorage instance = WebSecureStorage._();

  factory WebSecureStorage() => instance;

  const WebSecureStorage._();

  @override
  Future<void> delete({String key}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Future<String> read({String key}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<Map<String, String>> readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final allStringValue = <String, String>{};
    for (final key in keys) {
      final value = await prefs.get(key);
      if (value is String) {
        allStringValue.putIfAbsent(key, () => value);
      }
    }
    return allStringValue;
  }

  @override
  Future<void> write({String key, String value}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
}

ISecureStorage getSecureStorage() => WebSecureStorage.instance;
