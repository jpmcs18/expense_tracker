import 'package:intl/intl.dart';
import './item.dart';

class ExpenseDetails {
  static const tblName = 'expense_details';
  static const colId = 'id';
  static const colDate = 'date';
  static const colQuantity = 'quantity';
  static const colPrice = 'price';
  static const colItemId = 'item_id';
  static const colExpenseId = 'expense_id';

  int id;
  DateTime date;
  int quantity;
  num price;
  int itemId;
  int expenseId;
  Item item;
  String get formatedDate {
    return DateFormat("yyyy-MM-dd HH:mm").format(date);
  }
  
  String get formatedPrice {
    return NumberFormat('#,###,##0.00').format(price);
  }
  String get formatedTotalPrice {
    return NumberFormat('#,###,##0.00').format(totalPrice);
  }
  num get totalPrice {
    return price * quantity;
  }

  ExpenseDetails(this.expenseId) {
    id = null;
    date = DateTime.now();
    quantity = 0;
    price = 0;
    itemId = null;
    item = null;
  }

  ExpenseDetails.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    quantity = map[colQuantity];
    price = map[colPrice];
    itemId = map[colItemId];
    expenseId = map[colExpenseId];
    date = DateTime.parse(map[colDate]);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colQuantity: quantity,
      colPrice: price,
      colItemId: itemId,
      colExpenseId: expenseId,
      colDate: formatedDate,
    };
    if (id != null) map[colId] = id;
    return map;
  }
}
