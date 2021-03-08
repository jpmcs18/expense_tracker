import 'package:expense_tracker/models/item.dart';

class ItemType {
  static const tblName = 'item_type';
  static const colId = 'id';
  static const colDescription = 'description';

  int id;
  String description;
  // int itemCount;

  Item items;

  ItemType() {
    id = null;
    description = '';
    items = null;
  }

  ItemType.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    description = map[colDescription];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{colDescription: description};
    if (id != null) map[colId] = id;
    return map;
  }
}
