import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import 'secure_storage_interface.dart';

class PlatformSecureStorage implements ISecureStorage {
  const PlatformSecureStorage();

  @override
  Future<void> delete({String key}) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } else if (Platform.isWindows) {
      final result = CredDelete(TEXT(key), CRED_TYPE_GENERIC, 0);
      if (result != TRUE) {
        final errorCode = GetLastError();
        debugPrint('Error ($result): $errorCode');
      }
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
    } else if (Platform.isWindows) {
      throw UnimplementedError();
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
    } else if (Platform.isWindows) {
      final credPointer = allocate<Pointer<CREDENTIAL>>();
      final result = CredRead(
        TEXT(key),
        CRED_TYPE_GENERIC,
        0,
        credPointer,
      );
      if (result != TRUE) {
        final errorCode = GetLastError();
        debugPrint('Error ($result): $errorCode');
        return '';
      }
      final cred = credPointer.value.ref;
      final blob = cred.CredentialBlob.asTypedList(cred.CredentialBlobSize);
      final value = utf8.decode(blob);
      CredFree(credPointer.value);
      free(credPointer);
      return value;
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
    } else if (Platform.isWindows) {
      throw UnimplementedError();
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
    } else if (Platform.isWindows) {
      final encodedValue = utf8.encode(value) as Uint8List;
      final blob = encodedValue.allocatePointer();

      final credential = CREDENTIAL.allocate()
        ..Type = CRED_TYPE_GENERIC
        ..TargetName = TEXT(key)
        ..Persist = CRED_PERSIST_LOCAL_MACHINE
        ..UserName = TEXT(key)
        ..CredentialBlob = blob
        ..CredentialBlobSize = encodedValue.length;

      final result = CredWrite(credential.addressOf, 0);

      if (result != TRUE) {
        final errorCode = GetLastError();
        debugPrint('Error ($result): $errorCode');
        return;
      }

      free(blob);
      free(credential.addressOf);
    } else {
      const storage = FlutterSecureStorage();
      await storage.write(
        key: key,
        value: value,
      );
    }
  }
}
