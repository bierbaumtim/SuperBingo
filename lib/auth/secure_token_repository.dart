import 'dart:convert';

import 'package:firedart/firedart.dart';
import 'package:flutter/foundation.dart';

import 'secure_storage_interface.dart';

const _tokenKey = 'token_key';

class SecureTokenRepository {
  final ISecureStorage _secureStorage;
  late ValueNotifier<Token?> token;

  SecureTokenRepository(this._secureStorage) {
    token = ValueNotifier(null);
    token.addListener(_saveToken);
  }

  Future<void> _saveToken() async {
    if (token.value != null) {
      await _secureStorage.write(
        key: _tokenKey,
        value: jsonEncode(_JsonToken(token.value!)),
      );
    } else {
      await _secureStorage.delete(key: _tokenKey);
    }
  }

  Future<void> loadToken() async {
    final tokenJson = await _secureStorage.read(key: _tokenKey);
    if (tokenJson.isNotEmpty) {
      final loadedToken = _JsonToken.fromJson(
        jsonDecode(tokenJson) as Map<String, dynamic>,
      );

      token.value = loadedToken.token;
    } else {
      token.value = Token('', '', '', DateTime(2000));
    }
  }

  void dispose() {
    token.dispose();
  }
}

class _JsonToken {
  final Token token;

  _JsonToken(this.token);

  factory _JsonToken.fromJson(Map<String, dynamic> map) => _JsonToken(
        Token.fromMap(map),
      );

  Map<String, dynamic> toJson() => token.toMap();
}
