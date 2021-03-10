import 'package:intl/intl.dart';

extension NumberFormatHelper on num {
  String format() {
    return NumberFormat.currency(locale: "en_US", symbol: "₱").format(this);
  }
}

extension DateFormatHelper on DateTime {
  String format({bool dateOnly = false}) {
    return DateFormat(dateOnly ? "yyyy-MM-dd" : "yyyy-MM-dd HH:mm").format(this);
  }
}
