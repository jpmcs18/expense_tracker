// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemType _$ItemTypeFromJson(Map<String, dynamic> json) {
  return ItemType(
    description: json['description'] as String?,
  )
    ..id = json['id'] as int?
    ..createdOn = DateTime.parse(json['created_on'] as String)
    ..modifiedOn = json['modified_on'] == null
        ? null
        : DateTime.parse(json['modified_on'] as String);
}

Map<String, dynamic> _$ItemTypeToJson(ItemType instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['created_on'] = instance.createdOn.toIso8601String();
  val['modified_on'] = instance.modifiedOn?.toIso8601String();
  val['description'] = instance.description;
  return val;
}
