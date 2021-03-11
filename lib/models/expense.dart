import 'package:json_annotation/json_annotation.dart';

part 'expense.g.dart';

@JsonSerializable()
class Expense {
  @JsonKey(includeIfNull: false)
  int? id;
  String? title;
  @JsonKey(ignore: true)
  DateTime? dateFrom;
  @JsonKey(ignore: true)
  DateTime? dateTo;
  @JsonKey(ignore: true)
  num? totalPrice;

  Expense({this.id, this.title, this.dateFrom, this.dateTo, this.totalPrice});

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}
