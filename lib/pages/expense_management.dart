import 'package:expense_tracker/databases/main_db.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/pages/expense_details_management.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/helpers/extensions/format_extension.dart';
import 'package:expense_tracker/helpers/constants/format_constant.dart';

class ExpenseManagement extends StatefulWidget {
  @override
  _ExpenseManagementState createState() => _ExpenseManagementState();
}

class _ExpenseManagementState extends State<ExpenseManagement> {
  MainDB db = MainDB.instance;
  Expense _selectedExpense = Expense();
  List<Expense> _expenses = [];
  final _ctrlTitle = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('Expenses')),
            IconButton(icon: Icon(Icons.add), onPressed: _manageExpenses),
            IconButton(icon: Icon(Icons.more_vert_rounded), onPressed: () {}),
          ],
        ),
      ),
      body: Card(
        child: Container(
          child: ListView.builder(
            itemCount: _expenses.length,
            itemBuilder: (context, index) {
              return Card(
                child: Dismissible(
                  key: Key(_expenses[index].id.toString()),
                  child: ListTile(
                    title: Container(
                      child: Row(
                        children: [
                          Expanded(child: Text(_expenses[index].title ?? ""))
                        ],
                      ),
                    ),
                    trailing: Text(
                      _expenses[index].totalPrice.format(),
                      style: TextStyle(fontSize: 20),
                    ),
                    subtitle: Text(_expenses[index].dateRange),
                    onTap: () {
                      _selectExpenses(_expenses[index]);
                    },
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
                      return await _deleteExpenses(_expenses[index].id, _expenses[index].title);
                    } else {
                      setState(() {
                        _selectedExpense = _expenses[index];
                      });
                      _manageExpenses();
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

  Future<bool?> _deleteExpenses(id, title) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
            title: Text(
              "Delete",
            ),
            content: Text(
              "Continue deleting Expense '$title'?\n\n(This action is irreversible.)",
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    var b = (await db.deleteExpense(id)) > 0;
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

  _selectExpenses(Expense expense) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return ExpenseDetailsManagement(expense);
      },
    )).whenComplete(() => _getExpenses());
  }

  _getExpenses() async {
    var expenses = await db.getExpenses();
    setState(() {
      _expenses = expenses;
    });
  }

  _manageExpenses() {
    setState(() {
      _ctrlTitle.text = _selectedExpense.title ?? "";
    });
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Manage Expense'),
          content: TextField(
            controller: _ctrlTitle,
            decoration: InputDecoration(labelText: 'Title'),
            onChanged: (value) {
              setState(() {
                _selectedExpense.title = value;
              });
            },
          ),
          actions: [
            TextButton(onPressed: _cancel, child: Text('Cancel')),
            TextButton(onPressed: _saveExpense, child: Text(_selectedExpense.id == null ? 'Insert' : 'Update'))
          ],
        );
      },
    );
  }

  _cancel() {
    setState(() {
      _selectedExpense = Expense();
      _ctrlTitle.clear();
    });

    Navigator.of(context).pop();
  }

  _saveExpense() async {
    if (_selectedExpense.id == null)
      await db.insertExpense(_selectedExpense);
    else
      await db.updateExpense(_selectedExpense);
    setState(() {
      _selectedExpense = Expense();
      _ctrlTitle.clear();
    });
    _getExpenses();
    Navigator.of(context).pop();
  }
}
