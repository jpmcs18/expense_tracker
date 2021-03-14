import 'package:intl/intl.dart';

extension NumberFormatHelper on num {
  String format() {
    return NumberFormat.currency(locale: "en_US", symbol: "₱").format(this);
  }
}

extension DateFormatHelper on DateTime {
  String format({bool dateOnly = false}) {
    return DateFormat(dateOnly ? "MMMM dd, yyyy" : "MMMM dd, yyyy hh:mm aaa").format(this);
  }

  String formatToMonth() {
    return DateFormat("MMMM").format(this);
  }

  String formatToMonthDay() {
    return DateFormat("MMMM dd").format(this);
  }

  String formatToYear() {
    return DateFormat("yyyy").format(this);
  }

  String formatToHour({bool dateOnly = false}) {
    return DateFormat("hh:mm aaa").format(this);
  }

  String formatToDayHour() {
    return DateFormat("EEEE, hh:mm aaa").format(this);
  }

  String formatToMonthDayHour() {
    return DateFormat("MMMM dd, hh:mm aaa").format(this);
  }

  String formatToDayHourYear() {
    return DateFormat("EEEE, hh:mm aaa yyyy").format(this);
  }

  String formatLocalize() {
    var diff = DateTime.now().difference(this);
    print(diff.inDays);
    if (this.format() == DateTime.now().format())
      return "Just Now";
    else if (diff.inMinutes >= 1 && diff.inDays == 0)
      return "Today at ${this.formatToHour()}";
    else if (diff.inDays == 1)
      return "Yesterday";
    else if (diff.inDays > 1 && this.formatToMonth() == DateTime.now().formatToMonth() && this.formatToYear() == DateTime.now().formatToYear())
      return this.formatToDayHour();
    else if (this.formatToMonth() != DateTime.now().formatToMonth() && this.formatToYear() == DateTime.now().formatToYear())
      return this.formatToMonthDayHour();
    else
      return this.format();
  }
}

class DateRangeFormatter {
  static String format(DateTime start, DateTime end) {
    if (start == end)
      return start.formatLocalize();
    else if (start.format(dateOnly: true) == end.format(dateOnly: true) && start.format(dateOnly: true) == DateTime.now().format(dateOnly: true))
      return "Today, ${start.formatToHour()} - ${end.formatToHour()}";
    else if (start.format(dateOnly: true) == end.format(dateOnly: true) && start.formatToYear() == DateTime.now().formatToYear())
      return "${start.formatToMonthDay()}, ${start.formatToHour()} - ${end.formatToHour()}";
    else if (start.format(dateOnly: true) == end.format(dateOnly: true) && start.formatToYear() != DateTime.now().formatToYear())
      return "${start.formatToMonth()} ${start.formatToDayHourYear()} - ${end.formatToDayHourYear()} ";
    else if (start.format(dateOnly: true) != end.format(dateOnly: true) && start.formatToYear() == DateTime.now().formatToYear())
      return "${start.formatToMonthDayHour()} - ${end.formatToMonthDayHour()}";
    else
      return "${start.format()} - ${end.format()}";
  }
}
