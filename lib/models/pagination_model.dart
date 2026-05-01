import 'package:abhay_app_v2/utils/json_utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pagination_model.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PaginationModel<T> {
  @JsonKey(fromJson: parseToInt)
  int? total;

  List<T> models;

  PaginationModel({
    this.total,
    this.models = const [],
  });

  factory PaginationModel.fromJsonList(Map<String, int> json, List<T> models) {
    return PaginationModel(
      models: models,
      total: json['total'] ?? 0,
    );
  }

  factory PaginationModel.fromJsonListToMeta(int? total, List<T> models) {
    return PaginationModel(
      models: models,
      total: total ?? 0,
    );
  }

  factory PaginationModel.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$PaginationModelFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) => _$PaginationModelToJson(this, toJsonT);
}
