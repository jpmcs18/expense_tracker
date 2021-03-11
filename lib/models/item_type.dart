import 'package:json_annotation/json_annotation.dart';

import 'model_base.dart';

part 'item_type.g.dart';

@JsonSerializable()
class ItemType extends ModelBase {
  String? description;
  @JsonKey(ignore: true)
  int reference = 0;

  ItemType({this.description});

  factory ItemType.fromJson(Map<String, dynamic> json) => _$ItemTypeFromJson(json);

  Map<String, dynamic> toJson() => _$ItemTypeToJson(this);
}
