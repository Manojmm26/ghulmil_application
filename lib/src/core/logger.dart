// lib/src/core/logger.dart
import 'package:flutter/foundation.dart';

class Logger {
  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ $message');
    }
  }

  static void error(String message) {
    if (kDebugMode) {
      print('❌ $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      print('⚠️ $message');
    }
  }

  static void debug(String message) {
    if (kDebugMode) {
      print('🔍 $message');
    }
  }
}
