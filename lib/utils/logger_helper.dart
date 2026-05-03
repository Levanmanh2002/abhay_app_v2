import 'dart:convert';
import 'dart:developer' as dev;

final loggerHelper = _LoggerHelper();

class _LoggerHelper {
  void log(String message, {String name = ''}) {
    dev.log(message, name: name);
  }

  void success(String message, {Object? error, StackTrace? stackTrace, String name = ''}) {
    dev.log('\x1B[32m[INFO] $message\x1B[0m', name: name);
  }

  void error(String message, {Object? error, StackTrace? stackTrace, String name = ''}) {
    dev.log('\x1B[31m[ERROR] $message\x1B[0m', name: name, error: error, stackTrace: stackTrace);
  }

  void warn(String message, {Object? error, StackTrace? stackTrace}) {
    dev.log('\x1B[33m[WARN] $message\x1B[0m', error: error, stackTrace: stackTrace);
  }

  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    dev.log('\x1B[34m[DEBUG] $message\x1B[0m', error: error, stackTrace: stackTrace);
  }

  void logWhite(String message, {Object? error, StackTrace? stackTrace, String name = ''}) {
    dev.log('\x1B[37m[INFO] $message\x1B[0m', name: name, error: error, stackTrace: stackTrace);
  }

  void logCyan(String message, {Object? error, StackTrace? stackTrace}) {
    dev.log('\x1B[36m[CYAN] $message\x1B[0m', error: error, stackTrace: stackTrace);
  }

  void logMagenta(String message, {Object? error, StackTrace? stackTrace, String name = ''}) {
    dev.log('\x1B[35m[MAGENTA] $message\x1B[0m', name: name, error: error, stackTrace: stackTrace);
  }

  void logBlue(String message, {Object? error, StackTrace? stackTrace, String name = ''}) {
    dev.log('\x1B[34m[BLUE] $message\x1B[0m', name: name, error: error, stackTrace: stackTrace);
  }

  void logYellow(String message, {Object? error, StackTrace? stackTrace, String name = ''}) {
    dev.log('\x1B[33m[YELLOW] $message\x1B[0m', name: name, error: error, stackTrace: stackTrace);
  }

  void logFullObject(Object data) {
    final json = const JsonEncoder.withIndent('  ').convert(data);
    const int chunkSize = 800;

    for (var i = 0; i < json.length; i += chunkSize) {
      final end = (i + chunkSize < json.length) ? i + chunkSize : json.length;
      loggerHelper.log(json.substring(i, end), name: 'FullObject');
    }
  }
}
