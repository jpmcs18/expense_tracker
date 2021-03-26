import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/modals/delete_record.dart';
import 'package:expense_management/modals/expenses/expense_manager.dart';
import 'package:expense_management/models/expenses/expense.dart';
import 'package:expense_management/pages/components/custom_dismissible.dart';
import 'package:expense_management/pages/expenses_segments/expense_details_management.dart';
import 'package:expense_management/pages/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/helpers/extensions/format_extension.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
            Expanded(child: Text('Expense Categories')),
            IconButton(icon: Icon(Icons.add), onPressed: _newExpense)
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _expenses.length,
        itemBuilder: (context, index) {
          return CustomDismissible(
              isTop: index == 0,
              isBottom: index == _expenses.length - 1,
              id: _expenses[index].id.toString(),
              child: ListTile(
                title: Container(
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(_expenses[index].title ?? "",
                              style: cardTitleStyle1))
                    ],
                  ),
                ),
                trailing: Text(
                  _expenses[index].totalPrice.format(),
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                subtitle: Text(_expenses[index].dateRange),
                onTap: () {
                  _selectExpenses(_expenses[index]);
                },
              ),
              onDelete: () async {
                return await _deleteExpenses(_expenses[index]) ?? false;
              },
              onEdit: () async {
                setState(() {
                  _selectedExpense = _expenses[index];
                });
                _manageExpenses();
              });
        },
      ),
    );
  }

  Future<bool?> _deleteExpenses(Expense obj) async {
    if (obj.reference > 0) {
      Fluttertoast.showToast(msg: "Unable to delete ${obj.title}");
      return false;
    }
    if ((await showDeleteRecordManager(
            context, "Deleting", "Do you want to delete ${obj.title}?")) ??
        false) {
      if ((await db.deleteExpense(obj.id ?? 0)) > 0) {
        _getExpenses();
        return true;
      }
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
    if ((await showExpenseManager(context, _selectedExpense)) ?? false)
      _getExpenses();
  }
}
