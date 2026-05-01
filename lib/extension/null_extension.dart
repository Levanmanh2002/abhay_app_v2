extension SanitizeJson on Map<String, dynamic> {
  Map<String, dynamic> emptyStringToNull() {
    return map((key, value) {
      if (value is String && value.isEmpty) return MapEntry(key, null);
      if (value is Map<String, dynamic>) return MapEntry(key, value.emptyStringToNull());
      if (value is List) {
        return MapEntry(key, value.map((e) => e is Map<String, dynamic> ? e.emptyStringToNull() : e).toList());
      }
      return MapEntry(key, value);
    });
  }
}
