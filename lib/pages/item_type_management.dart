import 'package:expense_tracker/databases/main_db.dart';
import 'package:expense_tracker/models/item.dart';
import 'package:flutter/material.dart';
import '../models/item_type.dart';
import 'package:expense_tracker/helpers/extensions/format_extension.dart';
import 'package:expense_tracker/helpers/constants/format_constant.dart';

class ItemTypeMangement extends StatefulWidget {
  @override
  _ItemTypeMangementState createState() => _ItemTypeMangementState();
}

class _ItemTypeMangementState extends State<ItemTypeMangement> {
  MainDB db = MainDB.instance;
  List<ItemType> _itemTypes = [];
  List<Item> _items = [];
  ItemType _selectedItemType = ItemType();
  final _ctrlItemTypeDesc = TextEditingController();

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
            IconButton(icon: Icon(Icons.add), onPressed: _manageItemType),
          ],
        ),
      ),
      body: Card(
        child: Container(
          child: ListView.builder(
            itemCount: _itemTypes.length,
            itemBuilder: (context, index) {
              return Card(
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
                      trailing: Text('${_getItemCount(_itemTypes[index].id)} item/s')),
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
        ),
      ),
    );
  }

  Future<bool?> _deleteItemType(id, desc) async {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Deleting",
          ),
          content: Text(
            "Do you want to delete $desc?",
          ),
          actions: [
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _getItemCount(int? itemType) {
    return _items.where((e) => e.itemTypeId == itemType).length;
  }

  _manageItemType() {
    setState(() {
      _ctrlItemTypeDesc.text = _selectedItemType.description ?? "";
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Manage Item Type'),
          content: TextField(
            controller: _ctrlItemTypeDesc,
            decoration: InputDecoration(labelText: 'Description'),
            onChanged: (value) {
              setState(() {
                _selectedItemType.description = value;
              });
            },
          ),
          actions: [
            TextButton(onPressed: _cancel, child: Text('Cancel')),
            TextButton(onPressed: _saveItemType, child: Text(_selectedItemType.id == null ? 'Insert' : 'Update'))
          ],
        );
      },
    );
  }

  _cancel() {
    setState(() {
      _selectedItemType = ItemType();
      _ctrlItemTypeDesc.clear();
    });
    Navigator.of(context).pop();
  }

  _saveItemType() async {
    if (_selectedItemType.id == null)
      await db.insertItemType(_selectedItemType);
    else
      await db.updateItemType(_selectedItemType);
    setState(() {
      _selectedItemType = ItemType();
      _ctrlItemTypeDesc.clear();
    });
    _getItemTypes();
    Navigator.of(context).pop();
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
