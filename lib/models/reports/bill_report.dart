import 'package:expense_management/models/bills/person.dart';

class BillReport {
  Person? person;
  int previousMonthElectricReading;
  int previousMonthWaterReading;
  int electricReading;
  int waterReading;
  int get electricConsumption {
    return electricReading < previousMonthElectricReading
        ? 0
        : electricReading - previousMonthElectricReading;
  }

  int get waterConsumption {
    return waterReading < previousMonthWaterReading
        ? 0
        : waterReading - previousMonthWaterReading;
  }

  num electricBillAmount = 0;
  num waterBillAmount = 0;

  num get totalBillAmount {
    return electricBillAmount + waterBillAmount;
  }

  BillReport(
      {this.person,
      this.previousMonthWaterReading = 0,
      this.previousMonthElectricReading = 0,
      this.waterReading = 0,
      this.electricReading = 0});
}
