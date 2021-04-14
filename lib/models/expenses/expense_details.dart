import 'package:expense_management/models/expenses/expense.dart';
import 'package:expense_management/models/expenses/item.dart';
import 'package:expense_management/models/model_base.dart';
import 'package:expense_management/models/titled_model_mixin.dart';
import 'package:json_annotation/json_annotation.dart';

part 'expense_details.g.dart';

@JsonSerializable()
class ExpenseDetails extends ModelBase with TitledModelMixin {
  DateTime date = DateTime.now();
  int quantity = 0;
  num price = 0;
  @JsonKey(name: 'item_id')
  int? itemId;
  @JsonKey(name: 'expense_id')
  int? expenseId;

  @JsonKey(ignore: true)
  Item? item;

  @JsonKey(ignore: true)
  Expense? expense;

  @JsonKey(ignore: true)
  num get totalPrice {
    return price * quantity;
  }

  ExpenseDetails({this.itemId, this.item, this.expenseId});

  factory ExpenseDetails.fromJson(Map<String, dynamic> json) =>
      _$ExpenseDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseDetailsToJson(this);
}
