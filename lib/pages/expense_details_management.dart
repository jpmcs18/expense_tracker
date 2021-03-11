import 'package:expense_tracker/databases/main_db.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/expense_details.dart';
import 'package:expense_tracker/models/item.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/helpers/extensions/format_extension.dart';
import 'package:expense_tracker/helpers/constants/format_constant.dart';

class ExpenseDetailsManagement extends StatefulWidget {
  final Expense expense;
  const ExpenseDetailsManagement(this.expense);
  @override
  _ExpenseDetailsManagementState createState() => _ExpenseDetailsManagementState();
}

class _ExpenseDetailsManagementState extends State<ExpenseDetailsManagement> {
  MainDB db = MainDB.instance;

  Expense _expense = Expense();
  final List<DropdownMenuItem<int>> _dropDownItems = [];
  final List<ExpenseDetails> _expensesDetails = [];
  List<Item> _items = [];
  String _currentDate = "";
  ExpenseDetails _selectedExpenseDetail = ExpenseDetails();
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
            Expanded(child: Text(_expense.title ?? "")),
            IconButton(icon: Icon(Icons.add), onPressed: _manageExpenseDetail),
          ],
        ),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: _expensesDetails.length,
          itemBuilder: (context, index) {
            return Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _expensesDetails[index].isHead ? Container(padding: EdgeInsets.only(left: 10.0, top: 10.0), child: Text(_expensesDetails[index].date.format(dateOnly: true))) : SizedBox(),
                  Card(
                    margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0, bottom: 0.0),
                    child: Dismissible(
                      key: Key(_expensesDetails[index].id.toString()),
                      child: ListTile(
                        title: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _expensesDetails[index].item!.description.toString(),
                                // style: TextStyle(fontSize: 25),
                              )
                            ],
                          ),
                        ),
                        subtitle: Text(_expensesDetails[index].date.formatToHour()),
                        trailing: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(
                            _expensesDetails[index].totalPrice.format(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Text(
                            "${_expensesDetails[index].price.format()} x ${_expensesDetails[index].quantity}",
                            style: TextStyle(fontWeight: FontWeight.w200),
                          ),
                        ]),
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
                          });
                          _manageExpenseDetail();
                          return false;
                        }
                      },
                    ),
                  )
                ],
              ),
            );
          },
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
        child: Text(item.description ?? ''),
        value: item.id,
      ));
    }

    setState(() {
      _dropDownItems.clear();
      _dropDownItems.addAll(dditem);
    });
  }

  _getExpenseDetails() async {
    var ed = await db.getExpenseDetails(_expense.id ?? 0);
    setState(() {
      _currentDate = "";
      _expensesDetails.clear();
      ed.map((e) {
        if (_currentDate.isEmpty || _currentDate != e.date.format(dateOnly: true)) {
          _currentDate = e.date.format(dateOnly: true);
          e.isHead = true;
          return e;
        }
      }).toList();
      _expensesDetails.addAll(ed);
    });
  }

  _initDetails() {
    setState(() {
      _selectedExpenseDetail = ExpenseDetails(expenseId: _expense.id);
    });
  }

  Future<bool?> _deleteExpenseDetail(id) async {
    return showDialog<bool?>(
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
                    _getExpenseDetails();
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
    setState(() {
      _ctrlDate.text = _selectedExpenseDetail.date.format();
      _ctrlQuantity.text = _selectedExpenseDetail.quantity.toString();
      _ctrlPrice.text = _selectedExpenseDetail.price.toString();
      _ctrlTotal.text = _selectedExpenseDetail.totalPrice.toString();
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Manage Item'),
          content: SingleChildScrollView(
              child: Form(
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
          )),
          actions: [
            TextButton(onPressed: _cancel, child: Text('Cancel')),
            TextButton(onPressed: _saveExpenseDetail, child: Text(_selectedExpenseDetail.id == null ? 'Insert' : 'Update')),
          ],
        );
      },
    );
  }

  _cancel() {
    _initDetails();
    setState(() {
      _ctrlDate.clear();
      _ctrlQuantity.clear();
      _ctrlPrice.clear();
      _ctrlTotal.clear();
    });

    Navigator.of(context).pop();
  }

  _getDate() async {
    var date = await showDatePicker(context: context, initialDate: _selectedExpenseDetail.date, firstDate: _firstDate, lastDate: _lastDate);
    if (date != null) {
      var time = await showTimePicker(context: context, initialTime: TimeOfDay(hour: _selectedExpenseDetail.date.hour, minute: _selectedExpenseDetail.date.minute));

      if (time != null) {
        setState(() {
          _selectedExpenseDetail.date = DateTime(date.year, date.month, date.day, time.hour, time.minute);
          _ctrlDate.text = _selectedExpenseDetail.date.format();
        });
      }
    }
  }

  _selectItem(int? itemId) {
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
