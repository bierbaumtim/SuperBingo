import 'package:firedart/firedart.dart';

import 'secure_token_repository.dart';

class ScureTokenStore extends TokenStore {
  final SecureTokenRepository _repository;

  ScureTokenStore(this._repository);
  @override
  void delete() {
    _repository.token.value = null;
  }

  @override
  Token read() => _repository.token.value;

  @override
  void write(Token token) {
    _repository.token.value = token;
  }
}
