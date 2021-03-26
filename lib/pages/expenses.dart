import 'package:expense_management/models/menu.dart';
import 'package:expense_management/pages/expenses_segments/expense_management.dart';
import 'package:expense_management/pages/expenses_segments/item_management.dart';
import 'package:expense_management/pages/expenses_segments/item_type_management.dart';
import 'package:flutter/material.dart';

class Expenses extends StatefulWidget {
  static const String route = '/expenses';

  @override
  _ExpensesState createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  Widget? _selectedWidget = Container();
  List<Menu> _menuItems = [
    Menu(location: 'Expenses', view: ExpenseManagement(), isSelected: true),
    Menu(location: 'Items', view: ItemManagement()),
    Menu(location: 'Item Types', view: ItemTypeManagement()),
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
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(right: 10),
        child: Row(
          children: _menuItems.map((menu) {
            return Expanded(
              child: InkWell(
                onTap: () {
                  _setAllFalse();
                  setState(() {
                    _selectedWidget = menu.view;
                    menu.isSelected = true;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(left: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: (menu.isSelected ?? false)
                        ? Theme.of(context).buttonColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  padding: EdgeInsets.all(15),
                  child: Text(
                    menu.location ?? "",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: (menu.isSelected ?? false)
                          ? Theme.of(context).accentColor
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            );
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
