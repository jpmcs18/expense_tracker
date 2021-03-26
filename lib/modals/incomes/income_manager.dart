import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/modals/modal_base.dart';
import 'package:expense_management/models/incomes/income.dart';
import 'package:expense_management/models/incomes/income_type.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:expense_management/helpers/extensions/format_extension.dart';

Future<bool?> showIncomeManager(context, income) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return IncomeManager(income);
    },
  );
}

class IncomeManager extends StatefulWidget {
  final Income income;

  const IncomeManager(this.income);

  @override
  State<StatefulWidget> createState() {
    return IncomeManagerState();
  }
}

class IncomeManagerState extends State<IncomeManager> {
  final MainDB db = MainDB.instance;

  Income _income = Income();

  final List<IncomeType> _incomeTypes = [];
  final List<DropdownMenuItem<int>> _dropDownIncomeTypes = [];
  final DateTime _firstDate = DateTime(DateTime.now().year - 1);
  final DateTime _lastDate = DateTime.now();
  final _ctrlDate = TextEditingController();
  final _ctrlIncomeAmount = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _income = widget.income;
      _ctrlDate.text = _income.date.format(dateOnly: true);
      _ctrlIncomeAmount.text = _income.amount.toString();
    });
    _initStatesAsync();
  }

  @override
  Widget build(BuildContext context) {
    return generateModalBody(
        Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                items: _dropDownIncomeTypes,
                value: _income.incomeTypeId,
                onChanged: _selectIncomeType,
                isExpanded: true,
                decoration: InputDecoration(labelText: 'Income Type'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Date'),
                controller: _ctrlDate,
                readOnly: true,
                onTap: () {
                  _getDate();
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Amount'),
                controller: _ctrlIncomeAmount,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _income.amount = num.parse(value);
                  });
                },
              ),
            ],
          ),
        ),
        [
          Expanded(child: TextButton(onPressed: _cancel, child: Text('Cancel'))),
          VerticalDivider(
            thickness: 1.5,
            indent: 7,
            endIndent: 7,
          ),
          Expanded(child: TextButton(onPressed: _saveIncome, child: Text(_income.id == null ? 'Insert' : 'Update')))
        ],
        header: "Manage Income");
  }

  _initStatesAsync() async {
    await _getIncomeTypes();
    await _setIncomeTypeToDropDownIncomeTypes();
  }

  _getDate() async {
    var date = await showDatePicker(context: context, initialDate: _income.date, firstDate: _firstDate, lastDate: _lastDate);
    if (date != null) {
      setState(() {
        _income.date = date;
        _ctrlDate.text = date.format(dateOnly: true);
      });
    }
  }

  _selectIncomeType(int? incomeTypeId) {
    setState(() {
      _income.incomeTypeId = incomeTypeId;
      _income.incomeType = _incomeTypes.where((element) => element.id == incomeTypeId).first;
    });
  }

  _getIncomeTypes() async {
    var incomeType = await db.getIncomeTypes();
    if (incomeType.length > 0) {
      setState(() {
        _incomeTypes.clear();
        _incomeTypes.addAll(incomeType);
      });
    }
  }

  _setIncomeTypeToDropDownIncomeTypes() async {
    List<DropdownMenuItem<int>> ddIncomeType = [];
    if (_incomeTypes.length > 0) {
      for (var IncomeType in _incomeTypes) {
        ddIncomeType.add(DropdownMenuItem(
          child: Text(IncomeType.description ?? ""),
          value: IncomeType.id,
        ));
      }
    }

    setState(() {
      _dropDownIncomeTypes.clear();
      _dropDownIncomeTypes.addAll(ddIncomeType);
    });
  }

  _cancel() {
    setState(() {
      _income = Income();
      _ctrlDate.clear();
      _ctrlIncomeAmount.clear();
    });
    Navigator.of(context).pop(false);
  }

  _saveIncome() async {
    try {
      if (_income.id == null)
        await db.insertIncome(_income);
      else
        await db.updateIncome(_income);
      setState(() {
        _income = Income();
        _ctrlDate.clear();
        _ctrlIncomeAmount.clear();
      });
      Navigator.of(context).pop(true);
    } catch (_) {
      Fluttertoast.showToast(msg: "Unable to ${_income.id == null ? 'insert' : 'update'} Income");
    }
  }
}
