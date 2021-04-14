import 'package:expense_management/models/incomes/income_type.dart';
import 'package:expense_management/models/model_base.dart';
import 'package:expense_management/models/titled_model_mixin.dart';
import 'package:json_annotation/json_annotation.dart';

part 'income.g.dart';

@JsonSerializable()
class Income extends ModelBase with TitledModelMixin {
  DateTime date = DateTime.now();
  num amount = 0;
  @JsonKey(name: 'income_type_id')
  int? incomeTypeId;

  @JsonKey(ignore: true)
  IncomeType? incomeType;

  Income({this.incomeTypeId});

  factory Income.fromJson(Map<String, dynamic> json) => _$IncomeFromJson(json);

  Map<String, dynamic> toJson() => _$IncomeToJson(this);
}
