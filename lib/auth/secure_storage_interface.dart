import 'web_secure_storage_impl.dart';

abstract class ISecureStorage {
  Future<void> write({
    required String key,
    required String value,
  });
  Future<String> read({
    required String key,
  });
  Future<void> delete({
    required String key,
  });
  Future<Map<String, String>> readAll();
  Future<void> deleteAll();

  factory ISecureStorage() => getSecureStorage();
}
