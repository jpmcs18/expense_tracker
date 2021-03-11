// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemType _$ItemTypeFromJson(Map<String, dynamic> json) {
  return ItemType(
    id: json['id'] as int,
    description: json['description'] as String,
  );
}

Map<String, dynamic> _$ItemTypeToJson(ItemType instance) => <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
    };
