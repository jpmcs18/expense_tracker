import 'package:expense_management/models/expenses/item_type.dart';
import 'package:expense_management/models/model_base.dart';
import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

@JsonSerializable()
class Item extends ModelBase {
  String? description;
  @JsonKey(name: 'item_type_id')
  int? itemTypeId;
  num amount = 0;

  @JsonKey(ignore: true)
  int reference = 0;

  @JsonKey(ignore: true)
  ItemType? itemType;

  @JsonKey(ignore: true)
  bool isHead = false;

  @JsonKey(ignore: true)
  bool isBottom = false;

  Item({this.itemTypeId, this.description});

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
