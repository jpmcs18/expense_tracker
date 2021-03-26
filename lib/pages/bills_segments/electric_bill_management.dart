import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/modals/bills/electric_bill_manager.dart';
import 'package:expense_management/modals/delete_record.dart';
import 'package:expense_management/models/bills/electric_bill.dart';
import 'package:expense_management/pages/components/custom_dismissible.dart';
import 'package:expense_management/pages/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/helpers/extensions/format_extension.dart';

class ElectricBillManagement extends StatefulWidget {
  @override
  ElectricBillManagementState createState() => ElectricBillManagementState();
}

class ElectricBillManagementState extends State<ElectricBillManagement> {
  MainDB db = MainDB.instance;
  List<ElectricBill> _electricBill = [];
  ElectricBill _selectedElectricBill = ElectricBill();

  @override
  void initState() {
    super.initState();
    _getElectricBills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('Electric Bills')),
            IconButton(icon: Icon(Icons.add), onPressed: _addNewElectricBill),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _electricBill.length,
        itemBuilder: (context, index) {
          return CustomDismissible(
              isTop: index == 0,
              isBottom: index == _electricBill.length - 1,
              id: _electricBill[index].id.toString(),
              child: ListTile(
                title: Container(
                    child: Row(
                  children: [
                    Expanded(child: Text(_electricBill[index].date.format(dateOnly: true), style: cardTitleStyle2))
                  ],
                )),
                subtitle: Text(_electricBill[index].createdOn.formatLocalize()),
                trailing: Text(
                      _electricBill[index].amount.format(),
                      style: TextStyle(fontSize: 15, color: Colors.red),
                    ),
              ),
              onDelete: () async {
                return await _deleteElectricBill(_electricBill[index]) ?? false;
              },
              onEdit: () async {
                setState(() {
                  _selectedElectricBill = _electricBill[index];
                });
                _manageElectricBill();
                return false;
              });
        },
      ),
    );
  }

  Future<bool?> _deleteElectricBill(ElectricBill obj) async {
    if ((await showDeleteRecordManager(context, "Deleting", "Do you want to delete bill for ${obj.date.format(dateOnly: true)}?")) ?? false) {
      if ((await db.deleteElectricBill(obj.id ?? 0)) > 0) {
        await _getElectricBills();
        return true;
      }
    }
    return false;
  }

  _addNewElectricBill() {
    setState(() {
      _selectedElectricBill = ElectricBill();
    });
    _manageElectricBill();
  }

  _manageElectricBill() async {
    if ((await showElectricBillManager(context, _selectedElectricBill)) ?? false) _getElectricBills();
  }

  _getElectricBills() async {
    var electricBills = await db.getElectricBills();
    if (this.mounted) {
      setState(() {
        _electricBill = electricBills;
      });
    }
  }
}
