import 'package:expense_management/models/model_base.dart';
import 'package:json_annotation/json_annotation.dart';

part 'income_type.g.dart';

@JsonSerializable()
class IncomeType extends ModelBase {
  String? description;
  @JsonKey(ignore: true)
  int reference = 0;

  IncomeType({this.description});

  factory IncomeType.fromJson(Map<String, dynamic> json) =>
      _$IncomeTypeFromJson(json);

  Map<String, dynamic> toJson() => _$IncomeTypeToJson(this);
}
