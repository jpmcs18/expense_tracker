import 'package:flutter/material.dart';

class Menu {
  String? location;
  Widget? view;
  bool? isSelected;
  Menu({this.location, this.view, this.isSelected = false});
}