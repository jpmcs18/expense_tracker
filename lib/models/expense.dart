import 'package:intl/intl.dart';

class Expense {
  static const tblName = 'expense';
  static const colId = 'id';
  static const colTitle = 'title';

  int id;
  String title;
  DateTime dateFrom;
  DateTime dateTo;
  num totalPrice;

  String get formatedDateFrom {
    return DateFormat.yMMMMd('en_US').format(dateFrom);
  }

  String get formatedDateTo {
    return DateFormat.yMMMMd('en_US').format(dateTo);
  }

  String get formatedTotalPrice {
    return NumberFormat('#,###,##0.00').format(totalPrice);
  }

  Expense() {
    id = null;
    title = '';
    dateFrom = null;
    dateTo = null;
    totalPrice = 0;
  }

  Expense.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    title = map[colTitle];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colTitle: title,
    };
    if (id != null) map[colId] = id;
    return map;
  }
}
