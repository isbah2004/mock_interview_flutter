import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Small centralized logger to replace print() usages.
/// Uses dart:developer.log so analyzer doesn't flag avoid_print.
class AppLogger {
  AppLogger._();

  static void log(String message, {String level = 'INFO'}) {
    // Only log when not in release mode. This ensures production builds
    // remain quiet while development builds still get logs.
    if (kReleaseMode) return;
    developer.log(message, name: level);
  }

  static void info(String message) => log(message, level: 'INFO');
  static void debug(String message) => log(message, level: 'DEBUG');
  static void warn(String message) => log(message, level: 'WARN');
  static void error(String message) => log(message, level: 'ERROR');
}
