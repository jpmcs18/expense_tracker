import 'package:json_annotation/json_annotation.dart';

import './item.dart';

part 'expense_details.g.dart';

@JsonSerializable()
class ExpenseDetails {
  @JsonKey(includeIfNull: false)
  int? id;
  DateTime? date;
  int? quantity;
  num? price;
  @JsonKey(name: 'item_id')
  int? itemId;
  @JsonKey(name: 'expense_id')
  int? expenseId;

  @JsonKey(ignore: true)
  Item? item;

  @JsonKey(ignore: true)
  num get totalPrice {
    return (price ?? 0) * (quantity ?? 0);
  }

  ExpenseDetails({this.id, this.date, this.quantity, this.price, this.itemId, this.item, this.expenseId});

  factory ExpenseDetails.fromJson(Map<String, dynamic> json) => _$ExpenseDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseDetailsToJson(this);
}
