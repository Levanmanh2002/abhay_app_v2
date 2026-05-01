import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';

class DebounceHandler<T> {
  final Duration _debounce;
  final void Function(T) onDebounce;
  final bool enableDebounce;
  Rx<bool>? debounceLoading;

  late T value;

  Timer? _debounceTimer;
  bool isDebounce = false;

  DebounceHandler({
    required T initialValue,
    this.debounceLoading,
    Duration? debounce,
    required this.onDebounce,
    this.enableDebounce = true,
  }) : _debounce = debounce ?? const Duration(seconds: 1) {
    value = initialValue;
  }

  void add(T newValue) async {
    value = newValue;
    if (!enableDebounce) {
      log('instant callback (no debounce): $newValue');
      onDebounce(value);
      return;
    }

    _updateDebounce(true);
    log('new value debounce $newValue');
    if (_debounceTimer != null) _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () {
      log('finish debounce');
      onDebounce(value);
      _debounceTimer?.cancel();
      _debounceTimer = null;
    });
  }

  void clear() {
    if (_debounceTimer != null) _debounceTimer?.cancel();
  }

  void cancel() {
    if (_debounceTimer != null) _debounceTimer?.cancel();
  }

  void _updateDebounce(bool value) {
    isDebounce = value;
    if (debounceLoading != null) {
      debounceLoading!.value = value;
    }
  }
}
