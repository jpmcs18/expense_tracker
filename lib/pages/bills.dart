import 'package:expense_management/models/menu.dart';
import 'package:expense_management/pages/bills_segments/electric_bill_management.dart';
import 'package:expense_management/pages/bills_segments/electric_reading_management.dart';
import 'package:expense_management/pages/bills_segments/person_management.dart';
import 'package:expense_management/pages/bills_segments/water_bill_management.dart';
import 'package:expense_management/pages/bills_segments/water_reading_management.dart';
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
    Menu(location: 'Electric Bills', view: ElectricBillManagement()),
    Menu(location: 'Electric Readings', view: ElectricReadingManagement()),
    Menu(location: 'Water Bills', view: WaterBillManagement()),
    Menu(location: 'Water Readings', view: WaterReadingManagement()),
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
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _menuItems.map((menu) {
              return InkWell(
                onTap: () {
                  _setAllFalse();
                  setState(() {
                    _selectedWidget = menu.view;
                    menu.isSelected = true;
                  });
                },
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: (menu.isSelected ?? false)
                        ? Theme.of(context).primaryColor
                        : Colors.white,
                  ),
                  padding: EdgeInsets.all(15),
                  child: Text(
                    menu.location ?? "",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: (menu.isSelected ?? false)
                            ? Colors.white
                            : Theme.of(context).primaryColor),
                  ),
                ),
              );
            }).toList(),
          ),
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
