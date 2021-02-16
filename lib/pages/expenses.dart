import 'package:expense_tracker/databases/main_db.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/expense_details.dart';
import 'package:flutter/material.dart';
import '../models/item.dart';

class Expenses extends StatefulWidget {
  @override
  _ExpensesState createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  MainDB db = MainDB.instance;
  Expense _selectedExpense = Expense();
  ExpenseDetails _selectedExpenseDetail = ExpenseDetails();
  List<Expense> _expenses = [];
  List<ExpenseDetails> _expenseDetails = [];
  num _totalExpenses = 0;
  List<DropdownMenuItem<Item>> _dropDownItems = [];
  final DateTime _firstDate = DateTime(DateTime.now().year - 1);
  final DateTime _lastDate = DateTime.now();
  final _ctrlPage = PageController(initialPage: 0);
  final _ctrlTitle = TextEditingController();
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
        allowImplicitScrolling: false,
        children: [
          //Expense
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
                              Expanded(child: Text(_expenses[index].title))
                            ],
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedExpense = _expenses[index];
                          });
                          _ctrlPage.jumpToPage(2);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          //Management Of Expense
          Card(
            child: Container(
              margin: EdgeInsets.all(5),
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Title'),
                    controller: _ctrlTitle,
                    onChanged: (value) {
                      setState(() {
                        _selectedExpense.title = value;
                      });
                    },
                  ),
                  RaisedButton(
                      child: Text(_selectedExpense.id == null ? 'Insert' : 'Update'),
                      onPressed: () {
                        _saveExpenses();
                      })
                ],
              ),
            ),
          ),
          //Expense Details
          Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                _addExpenseDetails();
              },
              child: Icon(Icons.add),
            ),
            bottomNavigationBar: RaisedButton(
              child: Text('Back'),
              onPressed: () {
                setState(() {
                  _selectedExpense = Expense();
                });
                _ctrlPage.jumpToPage(0);
              },
            ),
            body: Card(
              child: Container(
                margin: EdgeInsets.all(5),
                child: ListView.builder(
                  itemCount: _expenseDetails.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Container(
                          child: Row(
                            children: [
                              Expanded(child: Text(_expenseDetails[index].item.description)),
                              Text(_expenseDetails[index].formatedTotalPrice)
                            ],
                          ),
                        ),
                        subtitle: Text(_expenseDetails[index].formatedDate),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          //Management Of Expense Details
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
                    value: _selectedExpenseDetail.item,
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
                  TextField(
                    decoration: InputDecoration(labelText: 'Total'),
                    controller: _ctrlTotal,
                    readOnly: true,
                  ),
                  RaisedButton(
                      child: Text(_selectedExpenseDetail.id == null ? 'Insert' : 'Update'),
                      onPressed: () {
                        _saveExpenseDetails();
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
      _selectedExpenseDetail.item = item;
      _selectedExpenseDetail.itemId = item.id;
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
    var id = await db.insertExpense(_selectedExpense);
    var expense = await db.getExpense(id);
    setState(() {
      _expenses.add(expense);
      _selectedExpense = Expense();
    });
    _ctrlPage.jumpToPage(0);
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

  _addExpenseDetails() {
    setState(() {
      _selectedExpenseDetail = ExpenseDetails();
      _selectedExpenseDetail.expenseId = _selectedExpense.id;
    });
    _ctrlPage.jumpToPage(3);
  }

  _saveExpenseDetails() async {
    var id = await db.insertExpenseDetails(_selectedExpenseDetail);
    var expenseDetail = await db.getExpenseDetail(id);
    setState(() {
      _expenseDetails.add(expenseDetail);
      _selectedExpenseDetail = ExpenseDetails();
    });
    _ctrlPage.jumpToPage(2);
  }

}
