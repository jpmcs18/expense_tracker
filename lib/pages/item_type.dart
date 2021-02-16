import 'package:expense_tracker/databases/main_db.dart';
import 'package:flutter/material.dart';
import '../models/item_type.dart';

class ItemTypes extends StatefulWidget {
  @override
  _ItemTypesState createState() => _ItemTypesState();
}

class _ItemTypesState extends State<ItemTypes> {
  MainDB db = MainDB.instance;
  List<ItemType> _itemTypes = [];
  ItemType _itemType = ItemType();
  final _ctrlItemTypeDesc = TextEditingController();
  final _ctrlPage = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _getItemTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(3),
        child: PageView(
        physics: NeverScrollableScrollPhysics(),
          controller: _ctrlPage,
          children: [
            Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    _addItemType();
                  },
                  child: Icon(Icons.add),
                ),
                body: Container(
                  child: Column(
                    children: [
                      Expanded(
                          child: Card(
                              child: ListView.builder(
                                itemCount: _itemTypes.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                      child: ListTile(
                                    title: Text(_itemTypes[index].description),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                            icon: Icon(Icons.update),
                                            onPressed: () {
                                              _updateItemType(_itemTypes[index]);
                                            }),
                                        IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () {
                                              _deleteItemType(_itemTypes[index]);
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
                  TextField(
                    controller: _ctrlItemTypeDesc,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  RaisedButton(
                    child: Text(_itemType.id == null ? 'Insert' : 'Update'),
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
  
  _addItemType() {
    _ctrlPage.jumpToPage(1);
  }

  _updateItemType(ItemType itemType) {
    _fillData(itemType);
    _ctrlPage.jumpToPage(1);
  }

  _deleteItemType(ItemType itemType) async {
    await db.deleteItemType(itemType.id);
    setState(() {
      _itemTypes.remove(itemType);
    });
  }

  _save() async {
    setState(() {
      _itemType.description = _ctrlItemTypeDesc.text;
    });

    if (_itemType.id == null) {
      _itemType.id = await db.insertItemType(_itemType);
      var itemType = await db.getItemType(_itemType.id);
      setState(() {
        _itemTypes.add(itemType);
      });
    } else {
      await db.updateItemType(_itemType);
      setState(() {
        _itemTypes = _itemTypes.map((e) {
          if (e.id == _itemType.id) e.description = _itemType.description;
          return e;
        }).toList();
      });
    }

    _clearData();
    _ctrlPage.jumpToPage(0);
  }

  _getItemTypes() async {
    var itemTypes = await db.getItemTypes();
    setState(() {
      _itemTypes = itemTypes;
    });
  }

  _clearData() {
    setState(() {
      _itemType = ItemType();
      _ctrlItemTypeDesc.clear();
    });
  }

  _fillData(ItemType itemType) {
    setState(() {
      _itemType.id = itemType.id;
      _itemType.description = itemType.description;
      _ctrlItemTypeDesc.text = itemType.description;
    });
  }
}
