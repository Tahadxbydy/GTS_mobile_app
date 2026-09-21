import 'package:flutter/foundation.dart';

/// ANSI Color Codes for terminal logging
enum LogColor {
  reset('\x1B[0m'),
  black('\x1B[30m'),
  red('\x1B[31m'),
  green('\x1B[32m'),
  yellow('\x1B[33m'),
  blue('\x1B[34m'),
  magenta('\x1B[35m'),
  cyan('\x1B[36m'),
  white('\x1B[37m'),
  brightRed('\x1B[91m'),
  brightGreen('\x1B[92m'),
  brightYellow('\x1B[93m'),
  brightBlue('\x1B[94m');

  final String code;
  const LogColor(this.code);
}

class CP {
  CP._(); // Private constructor

  /// Generic log method with custom color and tag
  static void printColor(
    Object? message, {
    LogColor color = LogColor.cyan,
    String tag = 'APP',
  }) {
    if (kDebugMode) {
      final timeStamp = DateTime.now()
          .toIso8601String()
          .split('T')
          .last
          .substring(0, 8);
      print('${color.code}[$timeStamp] [$tag]: $message${LogColor.reset.code}');
    }
  }

  /// Informational messages (Blue)
  static void info(Object? message, {String tag = 'INFO'}) {
    printColor(message, color: LogColor.brightBlue, tag: tag);
  }

  /// Success state messages (Green)
  static void success(Object? message, {String tag = 'SUCCESS'}) {
    printColor(message, color: LogColor.brightGreen, tag: tag);
  }

  /// Warning messages (Yellow)
  static void warning(Object? message, {String tag = 'WARN'}) {
    printColor(message, color: LogColor.brightYellow, tag: tag);
  }

  /// Error messages (Red)
  static void error(Object? message, {Object? error, String tag = 'ERROR'}) {
    final formattedMessage = error != null
        ? '$message | Error: $error'
        : message;
    printColor(formattedMessage, color: LogColor.brightRed, tag: tag);
  }

  /// Network/API specific logs (Magenta)
  static void network(Object? message, {String tag = 'NETWORK'}) {
    printColor(message, color: LogColor.magenta, tag: tag);
  }
}
