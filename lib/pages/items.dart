import 'package:expense_tracker/databases/main_db.dart';
import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/item_type.dart';

class Items extends StatefulWidget {
  @override
  _ItemsState createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  MainDB db = MainDB.instance;
  List<Item> _items = [];
  List<DropdownMenuItem<ItemType>> _dropDownItemTypes = [];
  Item _item = Item();
  final _ctrlItemDesc = TextEditingController();
  final _ctrlPage = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _setItemTypeToDropDownItemTypes();
    _getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(3),
        child: PageView(
          allowImplicitScrolling: false,
          controller: _ctrlPage,
          children: [
            Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    _addItem();
                  },
                  child: Icon(Icons.add),
                ),
                body: Container(
                  child: Column(
                    children: [
                      Expanded(
                          child: Card(
                              child: ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          return Card(
                              child: ListTile(
                            title: Text(_items[index].description),
                            subtitle: Text(_items[index].itemType.description),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                    icon: Icon(Icons.update),
                                    onPressed: () {
                                      _updateItem(_items[index]);
                                    }),
                                IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteItem(_items[index]);
                                    })
                              ],
                            ),
                          ));
                        },
                      )))
                    ],
                  ),
                )),
            Card(
                child: Container(
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DropdownButtonFormField(
                    items: _dropDownItemTypes,
                    value: _item.itemType,
                    onChanged: _selectItemType,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: 'Item'),
                  ),
                  TextField(
                    controller: _ctrlItemDesc,
                    decoration: InputDecoration(labelText: 'Item Description'),
                  ),
                  RaisedButton(
                    child: Text(_item.id == null ? 'Insert' : 'Update'),
                    onPressed: () {
                      _save();
                    },
                  )
                ],
              ),
            )),
          ],
        ));
  }

  _setItemTypeToDropDownItemTypes() async {
    List<DropdownMenuItem<ItemType>> dditemType = [];
    var itemTypes = await db.getItemTypes();
    for (var itemType in itemTypes) {
      dditemType.add(DropdownMenuItem(
        child: Text(itemType.description),
        value: itemType,
      ));
    }

    setState(() {
      _dropDownItemTypes = dditemType;
    });
  }

  _selectItemType(ItemType itemType) {
    setState(() {
      _item.itemType = itemType;
      _item.itemTypeId = itemType.id;
    });
  }

  _addItem() {
    _ctrlPage.jumpToPage(1);
  }

  _updateItem(Item item) {
    _fillData(item);
    _ctrlPage.jumpToPage(1);
  }

  _deleteItem(Item item) async {
    await db.deleteItem(item.id);
    setState(() {
      _items.remove(item);
    });
  }

  _save() async {
    setState(() {
      _item.description = _ctrlItemDesc.text;
    });

    if (_item.id == null) {
      _item.id = await db.insertItem(_item);
      var item = await db.getItem(_item.id);
      setState(() {
        _items.add(item);
      });
    } else {
      await db.updateItem(_item);
      setState(() {
        _items = _items.map((e) {
          if (e.id == _item.id) e.description = _item.description;
          return e;
        }).toList();
      });
    }

    _clearData();
    _ctrlPage.jumpToPage(0);
  }

  _getItems() async {
    var items = await db.getItems();
    setState(() {
      _items = items;
    });
  }

  _clearData() {
    setState(() {
      _item = Item();
      _ctrlItemDesc.clear();
    });
  }

  _fillData(Item item) {
    setState(() {
      _item.id = item.id;
      _item.description = item.description;
      _ctrlItemDesc.text = item.description;
    });
  }
}
