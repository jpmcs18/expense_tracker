import 'package:json_annotation/json_annotation.dart';

class ModelBase {
  @JsonKey(includeIfNull: false)
  int? id;
  @JsonKey(name: "created_on")
  DateTime createdOn = DateTime.now();
  @JsonKey(name: "modified_on")
  DateTime? modifiedOn;
}
