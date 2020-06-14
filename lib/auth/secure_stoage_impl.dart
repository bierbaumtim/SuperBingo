import 'package:flutter/foundation.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'secure_storage_interface.dart';

class PlatformSecureStorage implements ISecureStorage {
  const PlatformSecureStorage();

  @override
  Future<void> delete({String key}) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } else {
      const storage = FlutterSecureStorage();
      await storage.delete(key: key);
    }
  }

  @override
  Future<void> deleteAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } else {
      const storage = FlutterSecureStorage();
      await storage.deleteAll();
    }
  }

  @override
  Future<String> read({String key}) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } else {
      const storage = FlutterSecureStorage();
      return storage.read(key: key);
    }
  }

  @override
  Future<Map<String, String>> readAll() async {
    if (kIsWeb) {
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
    } else {
      const storage = FlutterSecureStorage();
      return storage.readAll();
    }
  }

  @override
  Future<void> write({String key, String value}) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      const storage = FlutterSecureStorage();
      await storage.write(
        key: key,
        value: value,
      );
    }
  }
}
