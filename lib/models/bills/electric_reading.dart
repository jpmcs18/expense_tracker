import 'package:expense_management/models/bills/person.dart';
import 'package:expense_management/models/model_base.dart';
import 'package:json_annotation/json_annotation.dart';

part 'electric_reading.g.dart';

@JsonSerializable()
class ElectricReading extends ModelBase {
  DateTime date = DateTime.now();
  int reading = 0;
  @JsonKey(name: 'person_id')
  int? personId;

  @JsonKey(ignore: true)
  Person? person;

  @JsonKey(ignore: true)
  bool isHead = false;

  @JsonKey(ignore: true)
  bool isBottom = false;

  ElectricReading();

  factory ElectricReading.fromJson(Map<String, dynamic> json) => _$ElectricReadingFromJson(json);
  Map<String, dynamic> toJson() => _$ElectricReadingToJson(this);
}
