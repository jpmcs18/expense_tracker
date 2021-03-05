import 'package:expense_tracker/databases/main_db.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/expense_details.dart';
import 'package:expense_tracker/models/item.dart';
import 'package:flutter/material.dart';

class ExpenseDetailsManagement extends StatefulWidget {
  final Expense expense;
  const ExpenseDetailsManagement(this.expense);
  @override
  _ExpenseDetailsManagementState createState() => _ExpenseDetailsManagementState();
}

class _ExpenseDetailsManagementState extends State<ExpenseDetailsManagement> {
  MainDB db = MainDB.instance;

  Expense _expense;
  List<DropdownMenuItem<int>> _dropDownItems = [];
  List<ExpenseDetails> _expensesDetails = [];
  List<Item> _items = [];
  ExpenseDetails _selectedExpenseDetail;
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
      _expense = widget.expense;
    });
    _initDetails();
    _initStateAsync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('Expense Details')),
            IconButton(icon: Icon(Icons.add), onPressed: _manageExpenseDetail),
          ],
        ),
      ),
      body: Card(
        child: Container(
          child: ListView.builder(
            itemCount: _expensesDetails.length,
            itemBuilder: (context, index) {
              return Card(
                child: Dismissible(
                  key: Key(_expensesDetails[index].id.toString()),
                  child: ListTile(
                    title: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _expensesDetails[index].item.description.toString(),
                            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          Text('Quantity : ${_expensesDetails[index].quantity.toString()}'),
                          Text('Price : ${_expensesDetails[index].formatedPrice}')
                        ],
                      ),
                    ),
                    subtitle: Text(_expensesDetails[index].formatedDate),
                    trailing: Text(
                      _expensesDetails[index].formatedTotalPrice,
                      style: TextStyle(fontSize: 20),
                    ),
                    onTap: null,
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
                      return await _deleteExpenseDetail(_expensesDetails[index].id);
                    } else {
                      setState(() {
                        _selectedExpenseDetail = _expensesDetails[index];
                        _ctrlDate.text = _selectedExpenseDetail.formatedDate;
                        _ctrlQuantity.text = _selectedExpenseDetail.quantity.toString();
                        _ctrlPrice.text = _selectedExpenseDetail.price.toString();
                        _ctrlTotal.text = _selectedExpenseDetail.totalPrice.toString();
                      });
                      _manageExpenseDetail();
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

  _initStateAsync() async {
    await _getItems();
    await _getExpenseDetails();
    await _setItemToDropDownItems();
  }

  _getItems() async {
    var items = await db.getItems();
    setState(() {
      _items = items;
    });
  }

  _setItemToDropDownItems() async {
    List<DropdownMenuItem<int>> dditem = [];
    for (var item in _items) {
      dditem.add(DropdownMenuItem(
        child: Text(item.description),
        value: item.id,
      ));
    }

    setState(() {
      _dropDownItems = dditem;
    });
  }

  _getExpenseDetails() async {
    var ed = await db.getExpenseDetails(_expense.id);
    setState(() {
      _expensesDetails = ed;
    });
  }

  _initDetails() {
    setState(() {
      _selectedExpenseDetail = ExpenseDetails(_expense.id);
    });
  }

Future<bool> _deleteExpenseDetail(id) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
            title: Text(
              "Deleting",
            ),
            content: Text(
              "Do you want to delete this expense detail?",
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    var b = (await db.deleteExpenseDetails(id)) > 0;
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
  _manageExpenseDetail() {
    print(_selectedExpenseDetail.item);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Manage Expense Detail'),
          content: Form(
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
                  value: _selectedExpenseDetail.itemId,
                  onChanged: _selectItem,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: 'Item'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Quantity'),
                  controller: _ctrlQuantity,
                  onChanged: (value) {
                    setState(() {
                      _selectedExpenseDetail.quantity = int.parse(value);
                      _ctrlTotal.text = _selectedExpenseDetail.totalPrice.toString();
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Price'),
                  controller: _ctrlPrice,
                  onChanged: (value) {
                    setState(() {
                      _selectedExpenseDetail.price = num.parse(value);
                      _ctrlTotal.text = _selectedExpenseDetail.totalPrice.toString();
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
          actions: [
            TextButton(onPressed: _saveExpenseDetail, child: Text(_selectedExpenseDetail.id == null ? 'Insert' : 'Update'))
          ],
        );
      },
    );
  }

  _getDate() async {
    var date = await showDatePicker(context: context, initialDate: _selectedExpenseDetail.date, firstDate: _firstDate, lastDate: _lastDate);
    if (date != null) {
      var time = await showTimePicker(context: context, initialTime: TimeOfDay(hour: _selectedExpenseDetail.date.hour, minute: _selectedExpenseDetail.date.minute));

      if (time != null) {
        setState(() {
          _selectedExpenseDetail.date = DateTime(date.year, date.month, date.day, time.hour, time.minute);
          _ctrlDate.text = _selectedExpenseDetail.formatedDate;
        });
      }
    }
  }

  _selectItem(int itemId) {
    setState(() {
      _selectedExpenseDetail.itemId = itemId;
      _selectedExpenseDetail.item = _items.where((element) => element.id == itemId).first;
    });
  }

  _saveExpenseDetail() async {
    if (_selectedExpenseDetail.id == null)
      await db.insertExpenseDetails(_selectedExpenseDetail);
    else
      await db.updateExpenseDetails(_selectedExpenseDetail);
    _initDetails();
    setState(() {
      _ctrlDate.clear();
      _ctrlQuantity.clear();
      _ctrlPrice.clear();
      _ctrlTotal.clear();
    });
    _getExpenseDetails();
    Navigator.of(context).pop();
  }
}
