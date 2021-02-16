import 'package:flutter/material.dart';
import './models/menu.dart';
import './pages/items.dart';
import './pages/expenses.dart';
import './pages/item_type.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _selectedWidget = Container();
  String _title = '';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Menu> _menuItems = [
    Menu(location: 'Item Type', view: ItemTypes()),
    Menu(location: 'Items', view: Items()),
    Menu(location: 'Expenses', view: Expenses()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      appBar: AppBar(
          title: Text(_title),
          leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                if (_scaffoldKey.currentState.isDrawerOpen == false) {
                  _scaffoldKey.currentState.openDrawer();
                } else {
                  _scaffoldKey.currentState.openEndDrawer();
                }
              })),
      body: Scaffold(
          key: _scaffoldKey,
          drawer: Drawer(
            child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: ListView.builder(
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_menuItems[index].location),
                    leading: _menuItems[index].isSelected ? Icon(Icons.star_outline) : null,
                    onTap: () {
                      if (!_menuItems[index].isSelected) Navigator.of(context).pop();
                      _setAllFalse();
                      setState(() {
                        _selectedWidget = _menuItems[index].view;
                        _menuItems[index].isSelected = true;
                        _title = _menuItems[index].location;
                      });
                    },
                  );
                },
              ))
            ]),
          ),
          body: _selectedWidget),
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
