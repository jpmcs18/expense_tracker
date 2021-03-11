// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseDetails _$ExpenseDetailsFromJson(Map<String, dynamic> json) {
  return ExpenseDetails(
    itemId: json['item_id'] as int?,
    expenseId: json['expense_id'] as int?,
  )
    ..id = json['id'] as int?
    ..createdOn = DateTime.parse(json['created_on'] as String)
    ..modifiedOn = json['modified_on'] == null
        ? null
        : DateTime.parse(json['modified_on'] as String)
    ..date = DateTime.parse(json['date'] as String)
    ..quantity = json['quantity'] as int
    ..price = json['price'] as num;
}

Map<String, dynamic> _$ExpenseDetailsToJson(ExpenseDetails instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['created_on'] = instance.createdOn.toIso8601String();
  val['modified_on'] = instance.modifiedOn?.toIso8601String();
  val['date'] = instance.date.toIso8601String();
  val['quantity'] = instance.quantity;
  val['price'] = instance.price;
  val['item_id'] = instance.itemId;
  val['expense_id'] = instance.expenseId;
  return val;
}
