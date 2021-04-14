import 'package:json_annotation/json_annotation.dart';

mixin TitledModelMixin {
  @JsonKey(ignore: true)
  bool isHead = false;

  @JsonKey(ignore: true)
  bool isBottom = false;
}
