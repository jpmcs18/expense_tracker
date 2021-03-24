import 'package:expense_management/models/model_base.dart';
import 'package:json_annotation/json_annotation.dart';

part 'person.g.dart';

@JsonSerializable()
class Person extends ModelBase {
  String? name;
  @JsonKey(ignore: true)
  int reference = 0;

  Person({this.name});

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

  Map<String, dynamic> toJson() => _$PersonToJson(this);
}
