import 'package:json_annotation/json_annotation.dart';

bool parseToBool(dynamic json) {
  if (json is bool) {
    return json;
  } else if (json is int) {
    return json == 1;
  }
  return false;
}

int? parseToInt(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    return int.tryParse(value);
  }
  if (value is num) {
    return value.toInt();
  }
  return null;
}

double? parseToDouble(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    return double.tryParse(value);
  }
  if (value is num) {
    return value.toDouble();
  }
  return null;
}

String? parseToString(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    return value;
  }

  return value.toString();
}

class EmptyListToNullConverter<T> implements JsonConverter<List<T>?, dynamic> {
  const EmptyListToNullConverter();

  @override
  List<T>? fromJson(dynamic json) {
    if (json == null) return null;
    return (json as List).map((e) => e as T).toList();
  }

  @override
  dynamic toJson(List<T>? object) {
    if (object == null || object.isEmpty) return null;
    return object;
  }
}

class ListToNullConverter<T> implements JsonConverter<List<T>?, dynamic> {
  final T Function(Map<String, dynamic> json) fromJsonT;
  final Map<String, dynamic> Function(T object) toJsonT;

  const ListToNullConverter({
    required this.fromJsonT,
    required this.toJsonT,
  });

  @override
  List<T>? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is! List) return null;

    return json.whereType<Map<String, dynamic>>().map(fromJsonT).toList();
  }

  @override
  dynamic toJson(List<T>? object) {
    if (object == null || object.isEmpty) return null;
    return object.map(toJsonT).toList();
  }
}
