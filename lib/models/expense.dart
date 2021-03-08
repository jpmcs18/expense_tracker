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
    if (dateFrom == null) return '---';
    return DateFormat("yyyy-MM-dd HH:mm").format(dateFrom);
  }

  String get formatedDateTo {
    if (dateTo == null) return '---';
    return DateFormat("yyyy-MM-dd HH:mm").format(dateTo);
  }

  String get formatedTotalPrice {
    if (totalPrice == null) return '0.00';
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
    print('expense id : $id');
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colTitle: title,
    };
    if (id != null) map[colId] = id;
    return map;
  }
}
