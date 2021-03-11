// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseDetails _$ExpenseDetailsFromJson(Map<String, dynamic> json) {
  return ExpenseDetails(
    id: json['id'] as int?,
    date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
    quantity: json['quantity'] as int?,
    price: json['price'] as num?,
    itemId: json['item_id'] as int?,
    expenseId: json['expense_id'] as int?,
  );
}

Map<String, dynamic> _$ExpenseDetailsToJson(ExpenseDetails instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['date'] = instance.date?.toIso8601String();
  val['quantity'] = instance.quantity;
  val['price'] = instance.price;
  val['item_id'] = instance.itemId;
  val['expense_id'] = instance.expenseId;
  return val;
}
