import 'package:expense_tracker/pages/expense_management.dart';
import 'package:flutter/material.dart';
import './models/menu.dart';
import 'pages/item_management.dart';
import 'pages/item_type_management.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget? _selectedWidget = Container();
  List<Menu> _menuItems = [
    Menu(location: 'Expenses', view: ExpenseManagement()),
    Menu(location: 'Items', view: ItemMangement()),
    Menu(location: 'Item Type', view: ItemTypeMangement()),
  ];

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedWidget = _menuItems[0].view;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      bottomNavigationBar: Card(
        margin: EdgeInsets.all(0),
        child: Row(
          children: _menuItems.map((menu) {
            return Expanded(child: TextButton(onPressed: () { 
              _setAllFalse();
                      setState(() {
                        _selectedWidget = menu.view;
                        menu.isSelected = true;
                      });
             }, child: Text(menu.location ?? ""),));
          }).toList(),
        ),
      ),
      body: _selectedWidget,
    );
  }

  _setAllFalse() {
    setState(() {
      for (int i = 0; i < _menuItems.length; i++) {
        _menuItems[i].isSelected = false;
      }
    });
  }
}
