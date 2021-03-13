import 'package:flutter/foundation.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../utils/configuration_utils.dart';

class LogService {
  static final LogService instance = LogService._();

  factory LogService() => instance;

  LogService._() {
    _disabled = false;
  }

  late bool _disabled;

  // ignore: use_setters_to_change_properties,avoid_positional_boolean_parameters
  @visibleForTesting
  // ignore: avoid_positional_boolean_parameters
  void setDisabled(bool disabled) {
    _disabled = disabled;
  }

  Future<void> recordError(
    dynamic exception,
    StackTrace stackTrace, {
    dynamic reason,
    Iterable<DiagnosticsNode> information = const [],
    bool? printDetails,
  }) {
    if (_disabled) return Future.value();
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
    if (_disabled) return Future.value();
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
