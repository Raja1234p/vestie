import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

/// Centralized application logger ensuring production safety
class AppLogger {
  AppLogger._();

  static void debug(String message, {String name = 'DEBUG'}) {
    if (kDebugMode) {
      dev.log(message, name: name);
    }
  }

  static void info(String message, {String name = 'INFO'}) {
    if (kDebugMode) {
      dev.log('🟢 $message', name: name);
    }
  }

  static void error(String message, {Object? error, StackTrace? stackTrace, String name = 'ERROR'}) {
    dev.log('🔴 $message', name: name, error: error, stackTrace: stackTrace);
    // TODO: Send to Crashlytics / Sentry here in production
  }
}
