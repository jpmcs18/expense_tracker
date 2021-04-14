import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/modals/bills/water_bill_manager.dart';
import 'package:expense_management/modals/delete_record.dart';
import 'package:expense_management/models/bills/water_bill.dart';
import 'package:expense_management/pages/components/custom_dismissible.dart';
import 'package:expense_management/pages/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/helpers/extensions/format_extension.dart';

class WaterBillManagement extends StatefulWidget {
  @override
  WaterBillManagementState createState() => WaterBillManagementState();
}

class WaterBillManagementState extends State<WaterBillManagement> {
  MainDB db = MainDB.instance;
  List<WaterBill> _waterBill = [];
  WaterBill _selectedWaterBill = WaterBill();

  @override
  void initState() {
    super.initState();
    _getWaterBills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('Water Bills')),
            IconButton(icon: Icon(Icons.add), onPressed: _addNewWaterBill),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _waterBill.length,
        itemBuilder: (context, index) {
          return CustomDismissible(
              isTop: _waterBill[index].isHead,
              isBottom: _waterBill[index].isBottom,
              header: _waterBill[index].date.year.toString(),
              headerTailing: _waterBill[index].isHead
                  ? _waterBill
                      .where((element) =>
                          element.date.year == _waterBill[index].date.year)
                      .fold<num>(0.0, (previousValue, element) {
                      return previousValue + element.amount;
                    }).format()
                  : '',
              id: _waterBill[index].id.toString(),
              child: ListTile(
                title: Container(
                    child: Row(
                  children: [
                    Expanded(
                        child: Text(_waterBill[index].date.formatToMonthYear(),
                            style: cardTitleStyle2))
                  ],
                )),
                subtitle: Text(_waterBill[index].createdOn.formatLocalize()),
                trailing: Text(
                  _waterBill[index].amount.format(),
                  style: TextStyle(fontSize: 15, color: Colors.red),
                ),
              ),
              onDelete: () async {
                return await _deleteWaterBill(_waterBill[index]) ?? false;
              },
              onEdit: () async {
                setState(() {
                  _selectedWaterBill = _waterBill[index];
                });
                _manageWaterBill();
                return false;
              });
        },
      ),
    );
  }

  Future<bool?> _deleteWaterBill(WaterBill obj) async {
    if ((await showDeleteRecordManager(context, "Deleting",
            "Do you want to delete bill for ${obj.date.formatToMonthYear()}?")) ??
        false) {
      if ((await db.deleteWaterBill(obj.id ?? 0)) > 0) {
        await _getWaterBills();
        return true;
      }
    }
    return false;
  }

  _addNewWaterBill() {
    setState(() {
      _selectedWaterBill = WaterBill();
    });
    _manageWaterBill();
  }

  _manageWaterBill() async {
    if ((await showWaterBillManager(context, _selectedWaterBill)) ?? false)
      _getWaterBills();
  }

  _getWaterBills() async {
    var waterBills = await db.getWaterBills();
    if (this.mounted) {
      setState(() {
        int _current = 0;
        _waterBill.clear();
        if (waterBills.length > 0) {
          for (int i = 0; i < waterBills.length; i++) {
            var e = waterBills[i];
            if (_current == 0 || _current != e.date.year) {
              _current = e.date.year;
              e.isHead = true;
              if (i != 0) {
                waterBills[i - 1].isBottom = true;
              }
            }
            _waterBill.add(e);
          }
          _waterBill.last.isBottom = true;
        } else {
          _waterBill.clear();
        }
      });
    }
  }
}
