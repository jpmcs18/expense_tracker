import 'package:expense_tracker/models/item_type.dart';

class Item {
  static const tblName = 'item';
  static const colId = 'id';
  static const colDescription = 'description';
  static const colItemTypeId = 'item_type_id';

  int id;
  String description;
  int itemTypeId;

  ItemType itemType;

  Item() {
    id = null;
    description = '';
    itemTypeId = null;
    itemType = null;
  }

  Item.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    description = map[colDescription];
    itemTypeId = map[colItemTypeId];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colDescription: description,
      colItemTypeId: itemTypeId,
    };
    if (id != null) map[colId] = id;
    return map;
  }
}
