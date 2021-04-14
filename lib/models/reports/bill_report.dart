import 'package:expense_management/models/bills/person.dart';

class BillReport {
  Person? person;
  int? previousMonthElectricReading;
  int? previousMonthWaterReading;
  int? electricReading;
  int? waterReading;
  int? get electricConsumption {
    return (electricReading ?? 0) - (previousMonthElectricReading ?? 0);
  }

  int? get waterConsumption {
    return (waterReading ?? 0) - (previousMonthWaterReading ?? 0);
  }

  num electricBillAmount = 0;
  num waterBillAmount = 0;

  num get totalBillAmount {
    return electricBillAmount + waterBillAmount;
  }

  BillReport(
      {this.person,
      this.previousMonthWaterReading,
      this.previousMonthElectricReading,
      this.waterReading,
      this.electricReading});
}
