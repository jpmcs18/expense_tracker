import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/modals/modal_base.dart';
import 'package:expense_management/models/expenses/item.dart';
import 'package:expense_management/models/expenses/item_type.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<bool?> showItemManager(context, item) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return ItemManager(item);
    },
  );
}

class ItemManager extends StatefulWidget {
  final Item item;

  const ItemManager(this.item);

  @override
  State<StatefulWidget> createState() {
    return ItemManagerState();
  }
}

class ItemManagerState extends State<ItemManager> {
  final MainDB db = MainDB.instance;

  Item _item = Item();

  final List<ItemType> _itemTypes = [];
  final List<DropdownMenuItem<int>> _dropDownItemTypes = [];
  final _ctrlItemDesc = TextEditingController();
  final _ctrlItemAmount = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _item = widget.item;
      _ctrlItemDesc.text = _item.description ?? "";
      _ctrlItemAmount.text = _item.amount.toString();
    });
    _initStatesAsync();
  }

  @override
  Widget build(BuildContext context) {
    return generateModalBody(
        Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                controller: _ctrlItemDesc,
                onChanged: (value) {
                  setState(() {
                    _item.description = value;
                  });
                },
              ),
              DropdownButtonFormField(
                items: _dropDownItemTypes,
                value: _item.itemTypeId,
                onChanged: _selectItemType,
                isExpanded: true,
                decoration: InputDecoration(labelText: 'Item Type'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Amount'),
                controller: _ctrlItemAmount,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _item.amount = num.parse(value);
                  });
                },
              ),
            ],
          ),
        ),
        [
          Expanded(
              child: TextButton(onPressed: _cancel, child: Text('Cancel'))),
          VerticalDivider(
            thickness: 1.5,
            indent: 7,
            endIndent: 7,
          ),
          Expanded(
              child: TextButton(
                  onPressed: _saveItem,
                  child: Text(_item.id == null ? 'Insert' : 'Update')))
        ],
        header: "Manage Item");
  }

  _initStatesAsync() async {
    await _getItemTypes();
    await _setItemTypeToDropDownItemTypes();
  }

  _selectItemType(int? itemTypeId) {
    setState(() {
      _item.itemTypeId = itemTypeId;
      _item.itemType =
          _itemTypes.where((element) => element.id == itemTypeId).first;
    });
  }

  _getItemTypes() async {
    var itemType = await db.getItemTypes();
    if (itemType.length > 0) {
      setState(() {
        _itemTypes.clear();
        _itemTypes.addAll(itemType);
      });
    }
  }

  _setItemTypeToDropDownItemTypes() async {
    List<DropdownMenuItem<int>> dditemType = [];
    if (_itemTypes.length > 0) {
      for (var itemType in _itemTypes) {
        dditemType.add(DropdownMenuItem(
          child: Text(itemType.description ?? ""),
          value: itemType.id,
        ));
      }
    }

    setState(() {
      _dropDownItemTypes.clear();
      _dropDownItemTypes.addAll(dditemType);
    });
  }

  _cancel() {
    setState(() {
      _item = Item();
      _ctrlItemDesc.clear();
      _ctrlItemAmount.clear();
    });
    Navigator.of(context).pop(false);
  }

  _saveItem() async {
    try {
      if (_item.id == null)
        await db.insertItem(_item);
      else
        await db.updateItem(_item);
      setState(() {
        _item = Item();
        _ctrlItemDesc.clear();
        _ctrlItemAmount.clear();
      });
      Navigator.of(context).pop(true);
    } catch (_) {
      Fluttertoast.showToast(
          msg: "Unable to ${_item.id == null ? 'insert' : 'update'} item");
    }
  }
}
