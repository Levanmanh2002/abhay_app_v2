import 'package:abhay_app_v2/widget/search/stream/debounce_handler.dart';
import 'package:flutter/material.dart';

class SearchStreamController {
  final void Function(String) onGetValue;
  final void Function(bool)? updateSearchingStatus;
  late final DebounceHandler<String> _searchDebounce;

  SearchStreamController({
    required this.onGetValue,
    this.updateSearchingStatus,
    String initialTxt = '',
    bool enableDebounce = true,
    Duration? debounceDuration,
  }) {
    value = initialTxt;
    _searchDebounce = DebounceHandler(
      initialValue: initialTxt,
      onDebounce: doOnData,
      enableDebounce: enableDebounce,
      debounce: debounceDuration,
    );
  }

  String value = '';

  final _searchStatusCtrl = ValueNotifier<bool>(false);
  ValueNotifier<bool> get searchStatus => _searchStatusCtrl;
  bool get isSearching => _searchStatusCtrl.value;

  void insertNewText(String newValue) async {
    if (value != newValue) {
      value = newValue;
      if (!isSearching) {
        updateSearchStatus(true);
      }
      _searchDebounce.add(newValue);
    }
  }

  void doOnData(String value) {
    if (isSearching) {
      updateSearchStatus(false);
      onGetValue(value);
    }
  }

  void updateSearchStatus(bool value) {
    if (updateSearchingStatus != null) {
      updateSearchingStatus!(value);
    }
    _searchStatusCtrl.value = value;
  }

  void dispose() {
    _searchDebounce.cancel();
    _searchStatusCtrl.dispose();
  }
}
