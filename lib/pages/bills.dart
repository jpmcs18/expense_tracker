import 'package:expense_management/models/menu.dart';
import 'package:expense_management/pages/bills_segments/person_management.dart';
import 'package:flutter/material.dart';

class Bills extends StatefulWidget {
  static const String route = '/bills';

  @override
  _BillsState createState() => _BillsState();
}

class _BillsState extends State<Bills> {
  Widget? _selectedWidget = Container();
  List<Menu> _menuItems = [
    Menu(location: 'Persons', view: PersonManagement(), isSelected: true),
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
        margin: EdgeInsets.all(0),
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
                  decoration: BoxDecoration(
                    color: (menu.isSelected ?? false)
                        ? Theme.of(context).buttonColor
                        : Colors.white,
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
