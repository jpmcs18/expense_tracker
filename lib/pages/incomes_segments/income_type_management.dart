import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/modals/delete_record.dart';
import 'package:expense_management/modals/incomes/income_type_manager.dart';
import 'package:expense_management/models/incomes/income_type.dart';
import 'package:expense_management/pages/components/custom_dismissible.dart';
import 'package:expense_management/pages/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:expense_management/helpers/extensions/format_extension.dart';

class IncomeTypeManagement extends StatefulWidget {
  @override
  IncomeTypeManagementState createState() => IncomeTypeManagementState();
}

class IncomeTypeManagementState extends State<IncomeTypeManagement> {
  MainDB db = MainDB.instance;
  List<IncomeType> _incomeTypes = [];
  IncomeType _selectedIncomeType = IncomeType();

  @override
  void initState() {
    super.initState();
    _getIncomeTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('Income Types')),
            IconButton(icon: Icon(Icons.add), onPressed: _addNewIncomeType),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _incomeTypes.length,
        itemBuilder: (context, index) {
          return CustomDismissible(
              isTop: index == 0,
              isBottom: index == _incomeTypes.length - 1,
              id: _incomeTypes[index].id.toString(),
              child: ListTile(
                title: Container(
                    child: Row(
                  children: [
                    Expanded(child: Text(_incomeTypes[index].description ?? "", style: cardTitleStyle2))
                  ],
                )),
                subtitle: Text(_incomeTypes[index].createdOn.formatLocalize()),
              ),
              onDelete: () async {
                return await _deleteIncomeType(_incomeTypes[index]) ?? false;
              },
              onEdit: () async {
                setState(() {
                  _selectedIncomeType = _incomeTypes[index];
                });
                _manageIncomeType();
                return false;
              });
        },
      ),
    );
  }

  Future<bool?> _deleteIncomeType(IncomeType obj) async {
    if (obj.reference > 0) {
      Fluttertoast.showToast(msg: "Unable to delete ${obj.description}");
      return false;
    }
    if ((await showDeleteRecordManager(context, "Deleting", "Do you want to delete ${obj.description}?")) ?? false) {
      if ((await db.deleteIncomeType(obj.id ?? 0)) > 0) {
        await _getIncomeTypes();
        return true;
      }
    }
    return false;
  }

  _addNewIncomeType() {
    setState(() {
      _selectedIncomeType = IncomeType();
    });
    _manageIncomeType();
  }

  _manageIncomeType() async {
    if ((await showIncomeTypeManager(context, _selectedIncomeType)) ?? false) _getIncomeTypes();
  }

  _getIncomeTypes() async {
    var incomeTypes = await db.getIncomeTypes();
    if (this.mounted) {
      setState(() {
        _incomeTypes = incomeTypes;
      });
    }
  }
}
