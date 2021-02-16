import 'package:intl/intl.dart';
import './item.dart';

class Expense {
  static const tblName = 'expense';
  static const colId = 'id';
  static const colDate = 'date';
  static const colQuantity = 'quantity';
  static const colPrice = 'price';
  static const colItemId = 'itemid';

  int id;
  DateTime date;
  int quantity;
  num price;
  int itemId;
  Item item;
  String get formatedDate {
    return DateFormat("yyyy-MM-dd HH:mm").format(date);
  }

  String get formatedTotalPrice {
    return NumberFormat.currency().format(totalPrice);
  }

  num get totalPrice {
    return price * quantity;
  }

  Expense() {
    id = null;
    date = DateTime.now();
    quantity = 0;
    price = 0;
    itemId = null;
    item = null;
  }

  Expense.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    quantity = map[colQuantity];
    price = map[colPrice];
    itemId = map[colItemId];
    date = DateTime.parse(map[colDate]);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colQuantity: quantity,
      colPrice: price,
      colItemId: itemId,
      colDate: formatedDate,
    };
    if (id != null) map[colId] = id;
    return map;
  }
}
