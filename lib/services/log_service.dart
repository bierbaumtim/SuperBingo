import 'package:flutter/foundation.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../utils/configuration_utils.dart';

class LogService {
  static final LogService instance = LogService._();

  factory LogService() => instance;

  LogService._() {
    _initialized = false;
  }

  bool _initialized;

  void initFirebase() {
    if (kIsWeb || isDesktop) return;
    // FirebaseCore.
  }

  Future<void> recordError(
    dynamic exception,
    StackTrace stackTrace, {
    dynamic reason,
    Iterable<DiagnosticsNode> information,
    bool printDetails,
  }) {
    if (!_initialized) {
      debugPrint('FirebaseCrashlytics is not initialized');
      return Future.value();
    }
    if (!kIsWeb || !isDesktop) {
      return FirebaseCrashlytics.instance.recordError(
        exception,
        stackTrace,
        reason: reason,
        information: information,
        printDetails: printDetails,
      );
    } else {
      return Future.value();
    }
  }

  Future<void> recordFlutterError(FlutterErrorDetails flutterErrorDetails) {
    if (!_initialized) {
      debugPrint('FirebaseCrashlytics is not initialized');
      return Future.value();
    }
    if (!kIsWeb || !isDesktop) {
      return FirebaseCrashlytics.instance.recordFlutterError(
        flutterErrorDetails,
      );
    } else {
      return Future.value();
    }
  }
}
