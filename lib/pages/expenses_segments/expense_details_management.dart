import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/modals/delete_record.dart';
import 'package:expense_management/modals/expenses/expense_detail_manager.dart';
import 'package:expense_management/models/expenses/expense.dart';
import 'package:expense_management/models/expenses/expense_details.dart';
import 'package:expense_management/pages/components/custom_dismissible.dart';
import 'package:expense_management/pages/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/helpers/extensions/format_extension.dart';

class ExpenseDetailsManagement extends StatefulWidget {
  final Expense expense;
  const ExpenseDetailsManagement(this.expense);
  @override
  _ExpenseDetailsManagementState createState() =>
      _ExpenseDetailsManagementState();
}

class _ExpenseDetailsManagementState extends State<ExpenseDetailsManagement> {
  MainDB db = MainDB.instance;

  Expense _expense = Expense();
  final List<ExpenseDetails> _expensesDetails = [];
  ExpenseDetails _selectedExpenseDetail = ExpenseDetails();

  @override
  void initState() {
    super.initState();
    setState(() {
      _expense = widget.expense;
    });
    _getExpenseDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text(_expense.title ?? "")),
            IconButton(icon: Icon(Icons.add), onPressed: _newExpenseDetail),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _expensesDetails.length,
        itemBuilder: (context, index) {
          return CustomDismissible(
            header: _expensesDetails[index].date.format(dateOnly: true),
            headerTailing: _getTotal(_expensesDetails[index].date),
            headerTailingColor: Colors.red,
            isTop: _expensesDetails[index].isHead,
            isBottom: _expensesDetails[index].isBottom,
            id: _expensesDetails[index].id.toString(),
            child: ListTile(
              title: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_expensesDetails[index].item!.description.toString(),
                        style: cardTitleStyle2)
                  ],
                ),
              ),
              subtitle: Text(_expensesDetails[index].date.formatToHour()),
              trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _expensesDetails[index].totalPrice.format(),
                      style: TextStyle(fontSize: 15, color: Colors.red),
                    ),
                    Text(
                      "${_expensesDetails[index].price.format()} x ${_expensesDetails[index].quantity}",
                      style: TextStyle(fontWeight: FontWeight.w200),
                    ),
                  ]),
            ),
            onDelete: () async {
              return await _deleteExpenseDetail(_expensesDetails[index]) ??
                  false;
            },
            onEdit: () async {
              setState(() {
                _selectedExpenseDetail = _expensesDetails[index];
              });
              _manageExpenseDetail();
              return false;
            },
          );
        },
      ),
    );
  }

  String _getTotal(DateTime date) {
    return _expensesDetails
        .where((element) => element.date.format() == date.format())
        .fold(0,
            (num previousValue, element) => previousValue + element.totalPrice)
        .format();
  }

  _getExpenseDetails() async {
    var ed = await db.getExpenseDetails(expenseId: _expense.id ?? 0);
    if (ed.length > 0) {
      setState(() {
        String _currentDate = "";
        _expensesDetails.clear();
        for (int i = 0; i < ed.length; i++) {
          var e = ed[i];
          if (_currentDate.isEmpty ||
              _currentDate != e.date.format(dateOnly: true)) {
            _currentDate = e.date.format(dateOnly: true);
            e.isHead = true;
            if (i != 0) {
              ed[i - 1].isBottom = true;
            }
          }
          _expensesDetails.add(e);
        }
        _expensesDetails.last.isBottom = true;
      });
    } else {
      setState(() {
        _expensesDetails.clear();
      });
    }
  }

  _initDetails() {
    setState(() {
      _selectedExpenseDetail = ExpenseDetails(expenseId: _expense.id);
    });
  }

  Future<bool?> _deleteExpenseDetail(ExpenseDetails obj) async {
    if ((await showDeleteRecordManager(context, "Deleting",
            "Do you want to delete ${obj.item?.description} in ${obj.date.format(dateOnly: true)}?")) ??
        false) {
      if ((await db.deleteExpenseDetails(obj.id ?? 0)) > 0) {
        _getExpenseDetails();
        return true;
      }
    }
    return false;
  }

  _newExpenseDetail() {
    _initDetails();
    _manageExpenseDetail();
  }

  _manageExpenseDetail() async {
    if ((await showExpenseDetailManager(context, _selectedExpenseDetail)) ??
        false) _getExpenseDetails();
  }
}
