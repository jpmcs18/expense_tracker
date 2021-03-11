import 'package:expense_tracker/databases/main_db.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/expense_details.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/helpers/extensions/format_extension.dart';

import 'components/delete_record.dart';
import 'components/expense_detail_manager.dart';

class ExpenseDetailsManagement extends StatefulWidget {
  final Expense expense;
  const ExpenseDetailsManagement(this.expense);
  @override
  _ExpenseDetailsManagementState createState() => _ExpenseDetailsManagementState();
}

class _ExpenseDetailsManagementState extends State<ExpenseDetailsManagement> {
  MainDB db = MainDB.instance;

  Expense _expense = Expense();
  final List<ExpenseDetails> _expensesDetails = [];
  String _currentDate = "";
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
          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _expensesDetails[index].isHead
                    ? Container(
                        padding: EdgeInsets.only(left: 20.0, top: 10.0),
                        child: Text(_expensesDetails[index].date.format(dateOnly: true)),
                      )
                    : SizedBox(),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(_expensesDetails[index].isHead ? 25 : 0),
                      topRight: Radius.circular(_expensesDetails[index].isHead ? 25 : 0),
                      bottomLeft: Radius.circular(_expensesDetails[index].isBottom ? 25 : 0),
                      bottomRight: Radius.circular(_expensesDetails[index].isBottom ? 25 : 0)
                    ),
                  ),
                  margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 0.5, bottom: 0.0),
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
                          style: TextStyle(fontSize: 15, color: Colors.red),
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
    );
  }

  _getExpenseDetails() async {
    var ed = await db.getExpenseDetails(_expense.id ?? 0);
    if (ed.length > 0) {
      setState(() {
        _currentDate = "";
        _expensesDetails.clear();
        for (int i = 0; i < ed.length; i++) {
          var e = ed[i];
          if (_currentDate.isEmpty || _currentDate != e.date.format(dateOnly: true)) {
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
    }
  }

  _initDetails() {
    setState(() {
      _selectedExpenseDetail = ExpenseDetails(expenseId: _expense.id);
    });
  }

  Future<bool?> _deleteExpenseDetail(id) async {
    if ((await showDeleteRecordManager(context, "Deleting", "Do you want to delete this expense detail?")) ?? false) {
      if ((await db.deleteExpenseDetails(id)) > 0) _getExpenseDetails();
      return true;
    }
    return false;
  }

  _newExpenseDetail() {
    _initDetails();
    _manageExpenseDetail();
  }

  _manageExpenseDetail() async {
    if ((await showExpenseDetailManager(context, _selectedExpenseDetail)) ?? false) _getExpenseDetails();
  }
}
