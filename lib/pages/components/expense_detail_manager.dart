import 'package:expense_tracker/databases/main_db.dart';
import 'package:expense_tracker/models/expense_details.dart';
import 'package:expense_tracker/models/item.dart';
import 'package:expense_tracker/pages/components/modal_base.dart';
import 'package:expense_tracker/helpers/extensions/format_extension.dart';
import 'package:flutter/material.dart';

Future<bool?> showExpenseDetailManager(context, expenseDetail) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return ExpenseDetailManager(expenseDetail);
    },
  );
}

class ExpenseDetailManager extends StatefulWidget {
  final ExpenseDetails expenseDetail;

  const ExpenseDetailManager(this.expenseDetail);

  @override
  State<StatefulWidget> createState() {
    return ExpenseDetailManagerState();
  }
}

class ExpenseDetailManagerState extends State<ExpenseDetailManager> {
  final MainDB db = MainDB.instance;

  ExpenseDetails _expenseDetail = ExpenseDetails();
  final List<Item> _items = [];

  final List<DropdownMenuItem<int>> _dropDownItems = [];
  final DateTime _firstDate = DateTime(DateTime.now().year - 1);
  final DateTime _lastDate = DateTime.now();
  final _ctrlDate = TextEditingController();
  final _ctrlQuantity = TextEditingController();
  final _ctrlPrice = TextEditingController();
  final _ctrlTotal = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _expenseDetail = widget.expenseDetail;
      _ctrlDate.text = _expenseDetail.date.format();
      _ctrlQuantity.text = _expenseDetail.quantity.toString();
      _ctrlPrice.text = _expenseDetail.price.toString();
      _ctrlTotal.text = _expenseDetail.totalPrice.toString();
    });
    _initStateAsync();
  }

  @override
  Widget build(BuildContext context) {
    return generateModalBody(
        Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Date & Time'),
                controller: _ctrlDate,
                readOnly: true,
                onTap: () {
                  _getDate();
                },
              ),
              DropdownButtonFormField(
                items: _dropDownItems,
                value: _expenseDetail.itemId,
                onChanged: _selectItem,
                isExpanded: true,
                decoration: InputDecoration(labelText: 'Item'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Quantity'),
                controller: _ctrlQuantity,
                onChanged: (value) {
                  setState(() {
                    _expenseDetail.quantity = int.parse(value);
                    _ctrlTotal.text = _expenseDetail.totalPrice.toString();
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                controller: _ctrlPrice,
                onChanged: (value) {
                  setState(() {
                    _expenseDetail.price = num.parse(value);
                    _ctrlTotal.text = _expenseDetail.totalPrice.toString();
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Total'),
                controller: _ctrlTotal,
                readOnly: true,
              ),
            ],
          ),
        ),
        [
          TextButton(onPressed: _cancel, child: Text('Cancel')),
          TextButton(onPressed: _saveExpenseDetail, child: Text(_expenseDetail.id == null ? 'Insert' : 'Update'))
        ],
        header: "Manage Expense Details");
  }

  _initStateAsync() async {
    await _getItems();
    await _setItemToDropDownItems();
  }

  _getItems() async {
    var items = await db.getItems();
    setState(() {
      _items.clear();
      _items.addAll(items);
    });
  }

  _setItemToDropDownItems() async {
    List<DropdownMenuItem<int>> dditem = [];
    for (var item in _items) {
      dditem.add(DropdownMenuItem(
        child: Text(item.description ?? ''),
        value: item.id,
      ));
    }

    setState(() {
      _dropDownItems.clear();
      _dropDownItems.addAll(dditem);
    });
  }

  _selectItem(int? itemId) {
    setState(() {
      _expenseDetail.itemId = itemId;
      _expenseDetail.item = _items.where((element) => element.id == itemId).first;
      _expenseDetail.price = _expenseDetail.item?.amount ?? 0;
      _ctrlPrice.text = _expenseDetail.price.toString();
    });
  }

  _getDate() async {
    var date = await showDatePicker(context: context, initialDate: _expenseDetail.date, firstDate: _firstDate, lastDate: _lastDate);
    if (date != null) {
      var time = await showTimePicker(context: context, initialTime: TimeOfDay(hour: _expenseDetail.date.hour, minute: _expenseDetail.date.minute));

      if (time != null) {
        setState(() {
          _expenseDetail.date = DateTime(date.year, date.month, date.day, time.hour, time.minute);
          _ctrlDate.text = _expenseDetail.date.format();
        });
      }
    }
  }

  _cancel() {
    setState(() {
      _ctrlDate.clear();
      _ctrlQuantity.clear();
      _ctrlPrice.clear();
      _ctrlTotal.clear();
    });

    Navigator.of(context).pop(false);
  }

  _saveExpenseDetail() async {
    if (_expenseDetail.id == null)
      await db.insertExpenseDetails(_expenseDetail);
    else
      await db.updateExpenseDetails(_expenseDetail);
    setState(() {
      _ctrlDate.clear();
      _ctrlQuantity.clear();
      _ctrlPrice.clear();
      _ctrlTotal.clear();
    });
    Navigator.of(context).pop(true);
  }
}
