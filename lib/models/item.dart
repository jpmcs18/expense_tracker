import 'package:expense_tracker/models/item_type.dart';
import 'package:json_annotation/json_annotation.dart';

import 'model_base.dart';

part 'item.g.dart';

@JsonSerializable()
class Item extends ModelBase {
  String? description;
  @JsonKey(name: 'item_type_id')
  int? itemTypeId;
  num amount = 0;

  @JsonKey(ignore: true)
  ItemType? itemType;

  Item({this.itemTypeId, this.description});

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
