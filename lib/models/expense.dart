import 'package:json_annotation/json_annotation.dart';

import 'model_base.dart';

part 'expense.g.dart';

@JsonSerializable()
class Expense extends ModelBase {
  String? title;
  @JsonKey(ignore: true)
  String dateRange = "";
  @JsonKey(ignore: true)
  num totalPrice = 0;

  @JsonKey(ignore: true)
  int reference = 0;

  Expense({this.title});

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}
