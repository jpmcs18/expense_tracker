import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/models/item_type.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/modals/modal_base.dart';

Future<bool?> showItemTypeManager(context, itemType) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return ItemTypeManager(itemType);
    },
  );
}

class ItemTypeManager extends StatefulWidget {
  final ItemType itemType;

  const ItemTypeManager(this.itemType);

  @override
  State<StatefulWidget> createState() {
    return ItemTypeManagerState();
  }
}

class ItemTypeManagerState extends State<ItemTypeManager> {
  final MainDB db = MainDB.instance;

  ItemType _itemType = ItemType();

  final _ctrlItemTypeDesc = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _itemType = widget.itemType;
      _ctrlItemTypeDesc.text = _itemType.description ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return generateModalBody(
        TextField(
          controller: _ctrlItemTypeDesc,
          decoration: InputDecoration(labelText: 'Description'),
          onChanged: (value) {
            setState(() {
              _itemType.description = value;
            });
          },
        ),
        [
          TextButton(onPressed: _cancel, child: Text('Cancel')),
          TextButton(
              onPressed: _saveItemType,
              child: Text(_itemType.id == null ? 'Insert' : 'Update'))
        ],
        header: "Manage Item Type");
  }

  _cancel() {
    setState(() {
      _itemType = ItemType();
      _ctrlItemTypeDesc.clear();
    });
    Navigator.of(context).pop(false);
  }

  _saveItemType() async {
    if (_itemType.id == null)
      await db.insertItemType(_itemType);
    else
      await db.updateItemType(_itemType);
    setState(() {
      _itemType = ItemType();
      _ctrlItemTypeDesc.clear();
    });
    Navigator.of(context).pop(true);
  }
}
