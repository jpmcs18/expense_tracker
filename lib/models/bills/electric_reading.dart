import 'package:expense_management/models/bills/person.dart';
import 'package:expense_management/models/model_base.dart';
import 'package:expense_management/models/titled_model_mixin.dart';
import 'package:json_annotation/json_annotation.dart';

part 'electric_reading.g.dart';

@JsonSerializable()
class ElectricReading extends ModelBase with TitledModelMixin {
  DateTime date = DateTime.now();
  int reading = 0;
  @JsonKey(name: 'person_id')
  int? personId;

  @JsonKey(ignore: true)
  Person? person;

  ElectricReading();

  factory ElectricReading.fromJson(Map<String, dynamic> json) =>
      _$ElectricReadingFromJson(json);
  Map<String, dynamic> toJson() => _$ElectricReadingToJson(this);
}
