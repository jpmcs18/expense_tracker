import 'package:expense_tracker/databases/main_db.dart';
import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/item_type.dart';

class ItemMangement extends StatefulWidget {
  @override
  _ItemMangementState createState() => _ItemMangementState();
}

class _ItemMangementState extends State<ItemMangement> {
  MainDB db = MainDB.instance;
  List<Item> _items = [];
  List<DropdownMenuItem<int>> _dropDownItemTypes = [];
  List<ItemType> _itemTypes = [];
  Item _selectedItem = Item();
  final _ctrlItemDesc = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initStatesAsync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('Items')),
            IconButton(icon: Icon(Icons.add), onPressed: _manageItems),
          ],
        ),
      ),
      body: Card(
        child: Container(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return Card(
                child: Dismissible(
                  key: Key(_items[index].id.toString()),
                  child: ListTile(
                    title: Text(_items[index].description),
                    subtitle: Text(_items[index].itemType.description),
                  ),
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
                      return await _deleteItems(_items[index].id);
                    } else {
                      setState(() {
                        _selectedItem = _items[index];
                        _ctrlItemDesc.text = _selectedItem.description;
                      });
                      _manageItems();
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

  _initStatesAsync() async {
    await _getItems();
    await _getItemTypes();
    await _setItemTypeToDropDownItemTypes();
  }

  _getItemTypes() async {
    var itemType = await db.getItemTypes();
    if (itemType != null) {
      setState(() {
        _itemTypes = itemType;
      });
    }
  }

  _setItemTypeToDropDownItemTypes() async {
    List<DropdownMenuItem<int>> dditemType = [];
    if (_itemTypes != null) {
      for (var itemType in _itemTypes) {
        dditemType.add(DropdownMenuItem(
          child: Text(itemType.description),
          value: itemType.id,
        ));
      }
    }

    setState(() {
      _dropDownItemTypes = dditemType;
    });
  }

  _manageItems() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Manage Item'),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  controller: _ctrlItemDesc,
                  onChanged: (value) {
                    setState(() {
                      _selectedItem.description = value;
                    });
                  },
                ),
                DropdownButtonFormField(
                  items: _dropDownItemTypes,
                  value: _selectedItem.itemTypeId,
                  onChanged: _selectItemType,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: 'Item Type'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: _saveItem, child: Text(_selectedItem.id == null ? 'Insert' : 'Update'))
          ],
        );
      },
    );
  }

  _saveItem() async {
    if (_selectedItem.id == null)
      await db.insertItem(_selectedItem);
    else
      await db.updateItem(_selectedItem);
    setState(() {
      _selectedItem = Item();
      _ctrlItemDesc.clear();
    });
    _getItems();
    Navigator.of(context).pop();
  }

  _selectItemType(int itemTypeId) {
    setState(() {
      _selectedItem.itemTypeId = itemTypeId;
      _selectedItem.itemType = _itemTypes.where((element) => element.id == itemTypeId).first;
    });
  }

  _getItems() async {
    var items = await db.getItems();
    print(items.length);
    if (items != null) {
      setState(() {
        _items = items;
      });
    }
  }

  Future<bool> _deleteItems(id) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
            title: Text(
              "Deleting",
            ),
            content: Text(
              "Do you want to delete this item?",
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    var b = (await db.deleteItem(id)) > 0;
                    Navigator.of(context).pop(b);
                  },
                  child: Text('Yes')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('No')),
            ]);
      },
    );
  }
}
