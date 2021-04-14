import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/modals/delete_record.dart';
import 'package:expense_management/modals/incomes/income_manager.dart';
import 'package:expense_management/models/incomes/income.dart';
import 'package:expense_management/pages/components/custom_dismissible.dart';
import 'package:expense_management/pages/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/helpers/extensions/format_extension.dart';

class IncomeManagement extends StatefulWidget {
  @override
  IncomeManagementState createState() => IncomeManagementState();
}

class IncomeManagementState extends State<IncomeManagement> {
  MainDB db = MainDB.instance;
  final List<Income> _incomes = [];
  Income _selectedIncome = Income();

  @override
  void initState() {
    super.initState();
    _getIncomes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('Incomes')),
            IconButton(icon: Icon(Icons.add), onPressed: _addNewIncome),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _incomes.length,
        itemBuilder: (context, index) {
          return CustomDismissible(
            header: _incomes[index].incomeType?.description ?? "",
            headerTailing: _getTotal(_incomes[index].incomeTypeId ?? 0),
            headerTailingColor: Colors.green,
            isTop: _incomes[index].isHead,
            isBottom: _incomes[index].isBottom,
            id: _incomes[index].id.toString(),
            child: ListTile(
                title: Text(_incomes[index].date.format(dateOnly: true),
                    style: cardTitleStyle2),
                subtitle: Text(_incomes[index].createdOn.formatLocalize()),
                trailing: Text(
                  _incomes[index].amount.format(),
                  style: TextStyle(color: Colors.green),
                )),
            onDelete: () async {
              return await _deleteIncomes(_incomes[index]) ?? false;
            },
            onEdit: () async {
              setState(() {
                _selectedIncome = _incomes[index];
              });
              await _manageIncome();
              return false;
            },
          );
        },
      ),
    );
  }

  String _getTotal(int incomeTypeId) {
    return _incomes
        .where((element) => element.incomeTypeId == incomeTypeId)
        .fold(0, (num previousValue, element) => previousValue + element.amount)
        .format();
  }

  _addNewIncome() {
    setState(() {
      _selectedIncome = Income();
    });
    _manageIncome();
  }

  _manageIncome() async {
    if ((await showIncomeManager(context, _selectedIncome)) ?? false)
      _getIncomes();
  }

  _getIncomes() async {
    var incomes = await db.getIncomes();
    print(incomes.length);
    if (incomes.length > 0) {
      setState(() {
        int _current = 0;
        _incomes.clear();
        for (int i = 0; i < incomes.length; i++) {
          var e = incomes[i];
          if (_current == 0 || _current != e.incomeTypeId) {
            _current = e.incomeTypeId ?? 0;
            e.isHead = true;
            if (i != 0) {
              incomes[i - 1].isBottom = true;
            }
          }
          _incomes.add(e);
        }
        _incomes.last.isBottom = true;
      });
    } else {
      setState(() {
        _incomes.clear();
      });
    }
  }

  Future<bool?> _deleteIncomes(Income obj) async {
    if ((await showDeleteRecordManager(context, "Deleting",
            "Do you want to delete income for ${obj.date.format(dateOnly: true)}?")) ??
        false) {
      if ((await db.deleteIncome(obj.id ?? 0)) > 0) {
        await _getIncomes();
        return true;
      }
    }
    return false;
  }
}
