import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/modals/modal_base.dart';
import 'package:expense_management/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<bool?> showExpenseManager(context, expense) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return ExpenseManager(expense);
    },
  );
}

class ExpenseManager extends StatefulWidget {
  final Expense expense;

  const ExpenseManager(this.expense);

  @override
  State<StatefulWidget> createState() {
    return ExpenseManagerState();
  }
}

class ExpenseManagerState extends State<ExpenseManager> {
  final MainDB db = MainDB.instance;
  final _ctrlTitle = TextEditingController();
  Expense _expense = Expense();

  @override
  void initState() {
    super.initState();
    setState(() {
      _expense = widget.expense;
      _ctrlTitle.text = _expense.title ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return generateModalBody(
        TextField(
            controller: _ctrlTitle,
            decoration: InputDecoration(labelText: 'Title'),
            onChanged: (value) {
              setState(() {
                _expense.title = value;
              });
            }),
        [
          Expanded(child: TextButton(onPressed: _cancel, child: Text('Cancel'))),
          VerticalDivider(thickness: 1.5, indent: 7, endIndent: 7,),
          Expanded(
            child: TextButton(
                onPressed: _saveExpense,
                child: Text(_expense.id == null ? 'Insert' : 'Update')),
          )
        ],
        header: "Manage Expense");
  }

  _cancel() {
    setState(() {
      _expense = Expense();
      _ctrlTitle.clear();
    });

    Navigator.of(context).pop(false);
  }

  _saveExpense() async {
    try {
      if (_expense.id == null)
        await db.insertExpense(_expense);
      else
        await db.updateExpense(_expense);
      setState(() {
        _expense = Expense();
        _ctrlTitle.clear();
      });
      Navigator.of(context).pop(true);
    } catch (_) {
      Fluttertoast.showToast(
          msg:
              "Unable to ${_expense.id == null ? 'insert' : 'update'} expense");
    }
  }
}
