import 'package:intl/intl.dart';
import 'package:expense_tracker/models/item_type.dart';

class Item {
  static const tblName = 'item';
  static const colId = 'id';
  static const colDescription = 'description';
  static const colItemTypeId = 'item_type_id';
  static const colItemAmount = 'item_amount';

  int id;
  String description;
  int itemTypeId;
  num amount;

  ItemType itemType;

  Item() {
    id = null;
    description = '';
    itemTypeId = null;
    itemType = null;
    amount = 0;
  }

  Item.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    description = map[colDescription];
    itemTypeId = map[colItemTypeId];
    amount = map[colItemAmount];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colDescription: description,
      colItemTypeId: itemTypeId,
      colItemAmount: amount
    };
    if (id != null) map[colId] = id;
    return map;
  }

  String get formatedAmount {
    return NumberFormat('#,###,##0.00').format(amount ?? 0);
  }
}
