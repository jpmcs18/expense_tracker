import 'package:json_annotation/json_annotation.dart';

import './item.dart';
import 'model_base.dart';

part 'expense_details.g.dart';

@JsonSerializable()
class ExpenseDetails extends ModelBase {
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
  bool isHead = false;
  
  @JsonKey(ignore: true)
  num get totalPrice {
    return price * quantity;
  }

  ExpenseDetails({this.itemId, this.item, this.expenseId});

  factory ExpenseDetails.fromJson(Map<String, dynamic> json) => _$ExpenseDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseDetailsToJson(this);
}
