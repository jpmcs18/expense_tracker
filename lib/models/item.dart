import 'package:intl/intl.dart';
import 'package:expense_tracker/models/item_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

@JsonSerializable(explicitToJson: true)
class Item {
  @JsonKey(includeIfNull: false)
  int? id;
  String? description;
  @JsonKey(name: 'item_type_id')
  int? itemTypeId;

  @JsonKey(ignore: true)
  ItemType? itemType;

  Item({this.id, this.itemTypeId, this.itemType});

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
