import 'package:expense_tracker/databases/main_db.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import '../models/item.dart';

class Expenses extends StatefulWidget {
  @override
  _ExpensesState createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  MainDB db = MainDB.instance;
  Expense _expense = Expense();
  List<Expense> _expenses = [];
  num _totalExpenses = 0;
  List<DropdownMenuItem<Item>> _dropDownItems = [];
  final DateTime _firstDate = DateTime(DateTime.now().year - 1);
  final DateTime _lastDate = DateTime.now();
  final _ctrlPage = PageController(initialPage: 0);
  final _ctrlDate = TextEditingController();
  final _ctrlQuantity = TextEditingController();
  final _ctrlPrice = TextEditingController();
  final _ctrlTotal = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setItemToDropDownItems();
    _getExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3),
      child: PageView(
        controller: _ctrlPage,
        children: [
          Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                _addExpenses();
              },
              child: Icon(Icons.add),
            ),
            body: Card(
              child: Container(
                margin: EdgeInsets.all(5),
                child: ListView.builder(
                  itemCount: _expenses.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Container(
                          child: Row(
                            children: [
                              Expanded(child: Text(_expenses[index].item.description)),
                              Text(_expenses[index].formatedTotalPrice)
                            ],
                          ),
                        ),
                        subtitle: Text(_expenses[index].formatedDate),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Card(
            child: Container(
              margin: EdgeInsets.all(5),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Date & Time'),
                    controller: _ctrlDate,
                    readOnly: true,
                    onTap: () {
                      _getDate();
                    },
                  ),
                  DropdownButtonFormField(
                    items: _dropDownItems,
                    value: _expense.item,
                    onChanged: _selectItem,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: 'Item'),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Quantity'),
                    controller: _ctrlQuantity,
                    onChanged: (value) {
                      setState(() {
                        _expense.quantity = int.parse(value);
                        _ctrlTotal.text = _expense.totalPrice.toString();
                      });
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Price'),
                    controller: _ctrlPrice,
                    onChanged: (value) {
                      setState(() {
                        _expense.price = num.parse(value);
                        _ctrlTotal.text = _expense.totalPrice.toString();
                      });
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Total'),
                    controller: _ctrlTotal,
                    readOnly: true,
                  ),
                  RaisedButton(
                      child: Text(_expense.id == null ? 'Insert' : 'Update'),
                      onPressed: () {
                        _saveExpenses();
                      })
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  _selectItem(Item item) {
    setState(() {
      _expense.item = item;
      _expense.itemId = item.id;
    });
  }

  _setItemToDropDownItems() async {
    List<DropdownMenuItem<Item>> dditem = [];
    var items = await db.getItems();
    for (var item in items) {
      dditem.add(DropdownMenuItem(
        child: Text(item.description),
        value: item,
      ));
    }

    setState(() {
      _dropDownItems = dditem;
    });
  }

  _getExpenses() async {
    var expenses = await db.getExpenses();
    setState(() {
      _expenses = expenses;
      _totalExpenses = _expenses.fold(0, (t, p) => t + p.totalPrice);
    });
  }

  _addExpenses() {
    _ctrlPage.jumpToPage(1);
  }

  _saveExpenses() async {
    print(_expense.date);
    var id = await db.insertExpense(_expense);
    var expense = await db.getExpense(id);
    setState(() {
      _expenses.add(expense);
      _expense = Expense();
    });
    _ctrlPage.jumpToPage(0);
  }

  _getDate() async {
    var date = await showDatePicker(context: context, initialDate: _expense.date, firstDate: _firstDate, lastDate: _lastDate);
    if (date != null) {
      var time = await showTimePicker(context: context, initialTime: TimeOfDay(hour: _expense.date.hour, minute: _expense.date.minute));

      if (time != null) {
        setState(() {
          _expense.date = DateTime(date.year, date.month, date.day, time.hour, time.minute);
          _ctrlDate.text = _expense.formatedDate;
        });
      }
    }
  }
}
