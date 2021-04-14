import 'package:expense_management/models/model_base.dart';
import 'package:expense_management/models/titled_model_mixin.dart';
import 'package:json_annotation/json_annotation.dart';

part 'water_bill.g.dart';

@JsonSerializable()
class WaterBill extends ModelBase with TitledModelMixin {
  DateTime date = DateTime.now();
  num amount = 0;

  WaterBill();

  factory WaterBill.fromJson(Map<String, dynamic> json) =>
      _$WaterBillFromJson(json);
  Map<String, dynamic> toJson() => _$WaterBillToJson(this);
}
