import 'package:flutter/material.dart';

class Menu {
  String? location;
  Widget? view;
  Icon? icon;
  bool? isSelected;
  Menu({this.location, this.view, this.icon, this.isSelected = false});
}
