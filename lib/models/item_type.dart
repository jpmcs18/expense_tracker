import 'package:json_annotation/json_annotation.dart';

part 'item_type.g.dart';

@JsonSerializable()
class ItemType {
  @JsonKey(includeIfNull: false)
  int? id;
  String? description;

  ItemType({this.id, this.description});

  factory ItemType.fromJson(Map<String, dynamic> json) => _$ItemTypeFromJson(json);

  Map<String, dynamic> toJson() => _$ItemTypeToJson(this);
}
