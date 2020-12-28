import 'secure_storage_interface.dart';

ISecureStorage getSecureStorage() => throw UnsupportedError(
      "This platform does not support a secure storage implementation.",
    );
