import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import 'secure_storage_interface.dart';

class WebSecureStorage implements ISecureStorage {
  static const WebSecureStorage instance = WebSecureStorage._();

  factory WebSecureStorage() => instance;

  const WebSecureStorage._();

  @override
  Future<void> delete({required String key}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Future<String> read({required String key}) async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeValue(prefs.getString(key) ?? '');
  }

  @override
  Future<Map<String, String>> readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final allStringValue = <String, String>{};
    for (final key in keys) {
      final value = prefs.get(key);
      if (value is String) {
        allStringValue.putIfAbsent(key, () => _decodeValue(value));
      }
    }
    return allStringValue;
  }

  @override
  Future<void> write({required String key, required String value}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, _encodeValue(value));
  }

  String _encodeValue(String value) {
    try {
      final gzip = GZipCodec();
      final zippedRawValue = gzip.encode(value.codeUnits);
      final base64Value = base64Encode(zippedRawValue);
      return String.fromCharCodes(
        gzip.encode(base64Value.codeUnits),
      );
    } on Object catch (_) {
      return value;
    }
  }

  String _decodeValue(String value) {
    try {
      final gzip = GZipCodec();
      final decodedBase64Value = gzip.decode(value.codeUnits);
      final zippedRawValue = base64Decode(
        String.fromCharCodes(decodedBase64Value),
      );
      return String.fromCharCodes(
        gzip.decode(zippedRawValue),
      );
    } catch (e) {
      return value;
    }
  }
}

ISecureStorage getSecureStorage() => WebSecureStorage.instance;
