import 'package:flutter/foundation.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../utils/configuration_utils.dart';

class LogService {
  static final LogService instance = LogService._();

  factory LogService() => instance;

  LogService._();

  Future<void> recordError(
    dynamic exception,
    StackTrace stackTrace, {
    dynamic reason,
    Iterable<DiagnosticsNode> information,
    bool printDetails,
  }) {
    if (isDesktop || kIsWeb) {
      debugPrint(exception.toString());
      debugPrintStack(stackTrace: stackTrace);
      return Future.value();
    } else {
      return FirebaseCrashlytics.instance.recordError(
        exception,
        stackTrace,
        reason: reason,
        information: information,
        printDetails: printDetails,
      );
    }
  }

  Future<void> recordFlutterError(FlutterErrorDetails flutterErrorDetails) {
    if (isDesktop || kIsWeb) {
      FlutterError.dumpErrorToConsole(flutterErrorDetails);
      return Future.value();
    } else {
      return FirebaseCrashlytics.instance.recordFlutterError(
        flutterErrorDetails,
      );
    }
  }
}
