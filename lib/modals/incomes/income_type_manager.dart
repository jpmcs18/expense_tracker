import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/models/incomes/income_type.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/modals/modal_base.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<bool?> showIncomeTypeManager(context, incomeType) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return IncomeTypeManager(incomeType);
    },
  );
}

class IncomeTypeManager extends StatefulWidget {
  final IncomeType incomeType;

  const IncomeTypeManager(this.incomeType);

  @override
  State<StatefulWidget> createState() {
    return IncomeTypeManagerState();
  }
}

class IncomeTypeManagerState extends State<IncomeTypeManager> {
  final MainDB db = MainDB.instance;

  IncomeType _incomeType = IncomeType();

  final _ctrlIncomeTypeDesc = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _incomeType = widget.incomeType;
      _ctrlIncomeTypeDesc.text = _incomeType.description ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return generateModalBody(
        TextField(
          controller: _ctrlIncomeTypeDesc,
          decoration: InputDecoration(labelText: 'Description'),
          onChanged: (value) {
            setState(() {
              _incomeType.description = value;
            });
          },
        ),
        [
          Expanded(child: TextButton(onPressed: _cancel, child: Text('Cancel'))),
          VerticalDivider(thickness: 1.5, indent: 7, endIndent: 7,),
          Expanded(
            child: TextButton(
                onPressed: _saveIncomeType,
                child: Text(_incomeType.id == null ? 'Insert' : 'Update')),
          )
        ],
        header: "Manage Income Type");
  }

  _cancel() {
    setState(() {
      _incomeType = IncomeType();
      _ctrlIncomeTypeDesc.clear();
    });
    Navigator.of(context).pop(false);
  }

  _saveIncomeType() async {
    try {
      if (_incomeType.id == null)
        await db.insertIncomeType(_incomeType);
      else
        await db.updateIncomeType(_incomeType);
      setState(() {
        _incomeType = IncomeType();
        _ctrlIncomeTypeDesc.clear();
      });
      Navigator.of(context).pop(true);
    } catch (_) {
      Fluttertoast.showToast(
          msg:
              "Unable to ${_incomeType.id == null ? 'insert' : 'update'} income type");
    }
  }
}
