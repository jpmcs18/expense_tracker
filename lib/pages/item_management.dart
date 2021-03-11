import 'package:expense_tracker/databases/main_db.dart';
import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/item_type.dart';
import 'package:expense_tracker/helpers/extensions/format_extension.dart';

import 'components/delete_record.dart';
import 'components/item_manager.dart';

class ItemMangement extends StatefulWidget {
  @override
  _ItemMangementState createState() => _ItemMangementState();
}

class _ItemMangementState extends State<ItemMangement> {
  MainDB db = MainDB.instance;
  final List<Item> _items = [];
  Item _selectedItem = Item();

  @override
  void initState() {
    super.initState();
    _getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('Items')),
            IconButton(icon: Icon(Icons.add), onPressed: _addNewItem),
          ],
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(5),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.only(top: 2),
            child: Dismissible(
              key: Key(_items[index].id.toString()),
              child: ListTile(title: Text(_items[index].description ?? ""), subtitle: Text(_items[index].itemType?.description ?? ""), trailing: Text(_items[index].amount.format())),
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
                  return await _deleteItems(_items[index].id, _items[index].description);
                } else {
                  setState(() {
                    _selectedItem = _items[index];
                  });
                  _manageItem();
                  return false;
                }
              },
            ),
          );
        },
      ),
    );
  }

  _addNewItem() {
    setState(() {
      _selectedItem = Item();
    });
    _manageItem();
  }

  _manageItem() async {
    if ((await showItemManager(context, _selectedItem)) ?? false) _getItems();
  }

  _getItems() async {
    var items = await db.getItems();
    print(items.length);
    if (items.length > 0) {
      setState(() {
        _items.clear();
        _items.addAll(items);
      });
    }
  }

  Future<bool?> _deleteItems(id, desc) async {
    if ((await showDeleteRecordManager(context, "Deleting", "Continue deleting Item '$desc'?")) ?? false) {
      return (await db.deleteItem(id)) > 0;
    }
    return false;
  }
}
