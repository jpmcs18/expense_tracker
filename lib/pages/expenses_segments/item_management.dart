import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/modals/delete_record.dart';
import 'package:expense_management/modals/expenses/item_manager.dart';
import 'package:expense_management/models/expenses/item.dart';
import 'package:expense_management/pages/components/custom_dismissible.dart';
import 'package:expense_management/pages/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/helpers/extensions/format_extension.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ItemManagement extends StatefulWidget {
  @override
  ItemManagementState createState() => ItemManagementState();
}

class ItemManagementState extends State<ItemManagement> {
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
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return CustomDismissible(
            header: _items[index].itemType?.description ?? "",
            headerTailing: _getTotal(_items[index].itemTypeId ?? 0),
            headerTailingColor: Colors.green,
            isTop: _items[index].isHead,
            isBottom: _items[index].isBottom,
            id: _items[index].id.toString(),
            child: ListTile(
                title: Text(_items[index].description ?? "",
                    style: cardTitleStyle2),
                subtitle: Text(_items[index].createdOn.formatLocalize()),
                trailing: Text(
                  _items[index].amount.format(),
                  style: TextStyle(color: Colors.green),
                )),
            onDelete: () async {
              return await _deleteItems(_items[index]) ?? false;
            },
            onEdit: () async {
              setState(() {
                _selectedItem = _items[index];
              });
              await _manageItem();
              return false;
            },
          );
        },
      ),
    );
  }

  String _getTotal(int itemTypeId) {
    return _items
        .where((element) => element.itemTypeId == itemTypeId)
        .fold(0, (num previousValue, element) => previousValue + element.amount)
        .format();
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
        int _current = 0;
        _items.clear();
        for (int i = 0; i < items.length; i++) {
          var e = items[i];
          if (_current == 0 || _current != e.itemTypeId) {
            _current = e.itemTypeId ?? 0;
            e.isHead = true;
            if (i != 0) {
              items[i - 1].isBottom = true;
            }
          }
          _items.add(e);
        }
        _items.last.isBottom = true;
      });
    } else {
      setState(() {
        _items.clear();
      });
    }
  }

  Future<bool?> _deleteItems(Item obj) async {
    if (obj.reference > 0) {
      Fluttertoast.showToast(msg: "Unable to delete ${obj.description}");
      return false;
    }
    if ((await showDeleteRecordManager(
            context, "Deleting", "Continue deleting '${obj.description}'?")) ??
        false) {
      if ((await db.deleteItem(obj.id ?? 0)) > 0) {
        await _getItems();
        return true;
      }
    }
    return false;
  }
}
