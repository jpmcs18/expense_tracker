import 'package:expense_tracker/databases/main_db.dart';
import 'package:expense_tracker/models/item.dart';
import 'package:flutter/material.dart';
import '../models/item_type.dart';
import 'package:expense_tracker/helpers/extensions/format_extension.dart';

import 'components/delete_record.dart';
import 'components/item_type_manager.dart';

class ItemTypeMangement extends StatefulWidget {
  @override
  _ItemTypeMangementState createState() => _ItemTypeMangementState();
}

class _ItemTypeMangementState extends State<ItemTypeMangement> {
  MainDB db = MainDB.instance;
  List<ItemType> _itemTypes = [];
  List<Item> _items = [];
  ItemType _selectedItemType = ItemType();

  @override
  void initState() {
    super.initState();
    _getItemTypes();
    _getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('Item Types')),
            IconButton(icon: Icon(Icons.add), onPressed: _addNewItemType),
          ],
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(5),
        itemCount: _itemTypes.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.only(top: 2),
            child: Dismissible(
              key: Key(_itemTypes[index].id.toString()),
              child: ListTile(
                  title: Container(
                      child: Row(
                    children: [
                      Expanded(child: Text(_itemTypes[index].description ?? ""))
                    ],
                  )),
                  subtitle: Text(_itemTypes[index].createdOn.formatLocalize()),
                  trailing: Text('${_itemTypes[index].reference} item/s')),
              background: Card(
                  color: Colors.green,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.fromLTRB(20, 5, 0, 5),
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  )),
              secondaryBackground: Card(
                  color: Colors.red,
                  child: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.fromLTRB(0, 5, 20, 5),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  )),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  return await _deleteItemType(_itemTypes[index].id, _itemTypes[index].description);
                } else {
                  setState(() {
                    _selectedItemType = _itemTypes[index];
                  });
                  _manageItemType();
                  return false;
                }
              },
            ),
          );
        },
      ),
    );
  }

  Future<bool?> _deleteItemType(id, desc) async {
    if ((await showDeleteRecordManager(context, "Deleting", "Do you want to delete $desc?")) ?? false) {
      return (await db.deleteItemType(id)) > 0;
    }
    return false;
  }

  _getItemCount(int? itemType) {
    return _items.where((e) => e.itemTypeId == itemType).length;
  }

  _addNewItemType() {
    setState(() {
      _selectedItemType = ItemType();
    });
    _manageItemType();
  }

  _manageItemType() async {
    if ((await showItemTypeManager(context, _selectedItemType)) ?? false) _getItemTypes();
  }

  _getItemTypes() async {
    var itemTypes = await db.getItemTypes();
    setState(() {
      _itemTypes = itemTypes;
    });
  }

  _getItems() async {
    var items = await db.getItems();
    print(items.length);
    if (items.length > 0) {
      setState(() {
        _items = items;
      });
    }
  }
}
