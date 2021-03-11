import 'package:expense_tracker/databases/main_db.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/pages/expense_details_management.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/helpers/extensions/format_extension.dart';

import 'components/delete_record.dart';
import 'components/expense_manager.dart';

class ExpenseManagement extends StatefulWidget {
  @override
  _ExpenseManagementState createState() => _ExpenseManagementState();
}

class _ExpenseManagementState extends State<ExpenseManagement> {
  MainDB db = MainDB.instance;
  Expense _selectedExpense = Expense();
  List<Expense> _expenses = [];

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
            IconButton(icon: Icon(Icons.add), onPressed: _newExpense)
          ],
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(5),
        itemCount: _expenses.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.only(top: 2),
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
    );
  }

  Future<bool?> _deleteExpenses(id, title) async {
    if ((await showDeleteRecordManager(context, "Deleting", "Do you want to delete this $title?")) ?? false) {
      return (await db.deleteExpense(id)) > 0;
    }
    return false;
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

  _newExpense() {
    setState(() {
      _selectedExpense = Expense();
    });
    _manageExpenses();
  }

  _manageExpenses() async {
    if ((await showExpenseManager(context, _selectedExpense)) ?? false) _getExpenses();
  }
}
