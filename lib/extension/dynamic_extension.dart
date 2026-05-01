extension NormalizeExt on Object? {
  dynamic get normalize {
    if (this == null) return '';
    if (this is List) {
      return (this as List).map((e) => (e as Object?).normalize).toList();
    }
    return this;
  }
}
