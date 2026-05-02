import 'dart:async';

class ApiErrorManager {
  static Completer<void>? _handling401Completer;

  static Future<void> handle401IfNeeded(Future<void> Function() callback) async {
    if (_handling401Completer != null) {
      return _handling401Completer!.future;
    }

    _handling401Completer = Completer<void>();
    try {
      await callback();
      _handling401Completer?.complete();
    } catch (e) {
      _handling401Completer?.completeError(e);
    } finally {
      _handling401Completer = null;
    }
  }
}
