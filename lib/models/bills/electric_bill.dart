import 'package:expense_management/models/model_base.dart';
import 'package:json_annotation/json_annotation.dart';

part 'electric_bill.g.dart';

@JsonSerializable()
class ElectricBill extends ModelBase {
  DateTime date = DateTime.now();
  num amount = 0;

  ElectricBill();

  factory ElectricBill.fromJson(Map<String, dynamic> json) => _$ElectricBillFromJson(json);
  Map<String, dynamic> toJson() => _$ElectricBillToJson(this);
}
