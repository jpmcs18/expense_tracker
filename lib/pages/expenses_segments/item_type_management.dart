import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/modals/ask.dart';
import 'package:expense_management/modals/expenses/item_type_manager.dart';
import 'package:expense_management/models/expenses/item_type.dart';
import 'package:expense_management/pages/components/custom_dismissible.dart';
import 'package:expense_management/pages/drawer.dart';
import 'package:expense_management/pages/expenses.dart';
import 'package:expense_management/pages/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/helpers/extensions/format_extension.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ItemTypeManagement extends StatefulWidget {
  @override
  _ItemTypeManagementState createState() => _ItemTypeManagementState();
}

class _ItemTypeManagementState extends State<ItemTypeManagement> {
  MainDB db = MainDB.instance;
  List<ItemType> _itemTypes = [];
  ItemType _selectedItemType = ItemType();

  @override
  void initState() {
    super.initState();
    _getItemTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(Expenses.route),
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('Item Types')),
            IconButton(icon: Icon(Icons.add), onPressed: _addNewItemType),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _itemTypes.length,
        itemBuilder: (context, index) {
          return CustomDismissible(
              isTop: index == 0,
              isBottom: index == _itemTypes.length - 1,
              id: _itemTypes[index].id.toString(),
              child: ListTile(
                title: Container(
                    child: Row(
                  children: [
                    Expanded(
                        child: Text(_itemTypes[index].description ?? "",
                            style: cardTitleStyle2))
                  ],
                )),
                subtitle: Text(_itemTypes[index].createdOn.formatLocalize()),
              ),
              onDelete: () async {
                return await _deleteItemType(_itemTypes[index]) ?? false;
              },
              onEdit: () async {
                setState(() {
                  _selectedItemType = _itemTypes[index];
                });
                _manageItemType();
                return false;
              });
        },
      ),
    );
  }

  Future<bool?> _deleteItemType(ItemType obj) async {
    if (obj.reference > 0) {
      Fluttertoast.showToast(msg: "Unable to delete ${obj.description}");
      return false;
    }
    if ((await showAskModal(context, "Deleting",
            "Do you want to delete ${obj.description}?")) ??
        false) {
      if ((await db.deleteItemType(obj.id ?? 0)) > 0) {
        await _getItemTypes();
        return true;
      }
    }
    return false;
  }

  _addNewItemType() {
    setState(() {
      _selectedItemType = ItemType();
    });
    _manageItemType();
  }

  _manageItemType() async {
    if ((await showItemTypeManager(context, _selectedItemType)) ?? false)
      _getItemTypes();
  }

  _getItemTypes() async {
    var itemTypes = await db.getItemTypes();
    setState(() {
      _itemTypes = itemTypes;
    });
  }
}
