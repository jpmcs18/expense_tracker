import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/modals/bills/electric_reading_manager.dart';
import 'package:expense_management/modals/delete_record.dart';
import 'package:expense_management/models/bills/electric_reading.dart';
import 'package:expense_management/pages/components/custom_dismissible.dart';
import 'package:expense_management/pages/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/helpers/extensions/format_extension.dart';

class ElectricReadingManagement extends StatefulWidget {
  @override
  ElectricReadingManagementState createState() => ElectricReadingManagementState();
}

class ElectricReadingManagementState extends State<ElectricReadingManagement> {
  MainDB db = MainDB.instance;
  List<ElectricReading> _electricReading = [];
  ElectricReading _selectedElectricReading = ElectricReading();

  @override
  void initState() {
    super.initState();
    _getElectricReadings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('Electric Readings')),
            IconButton(icon: Icon(Icons.add), onPressed: _addNewElectricReading),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _electricReading.length,
        itemBuilder: (context, index) {
          return CustomDismissible(
              isTop: _electricReading[index].isHead,
              isBottom: _electricReading[index].isBottom,
              header: _electricReading[index].person?.name ?? '',
              id: _electricReading[index].id.toString(),
              child: ListTile(
                title: Container(
                    child: Row(
                  children: [
                    Expanded(child: Text(_electricReading[index].date.format(dateOnly: true), style: cardTitleStyle2))
                  ],
                )),
                subtitle: Text(_electricReading[index].createdOn.formatLocalize()),
                trailing: Text(
                  _electricReading[index].reading.toString(),
                  style: TextStyle(fontSize: 15),
                ),
              ),
              onDelete: () async {
                return await _deleteElectricReading(_electricReading[index]) ?? false;
              },
              onEdit: () async {
                setState(() {
                  _selectedElectricReading = _electricReading[index];
                });
                _manageElectricReading();
                return false;
              });
        },
      ),
    );
  }

  Future<bool?> _deleteElectricReading(ElectricReading obj) async {
    if ((await showDeleteRecordManager(context, "Deleting", "Do you want to delete reading for ${obj.date.format(dateOnly: true)}?")) ?? false) {
      if ((await db.deleteElectricReading(obj.id ?? 0)) > 0) {
        await _getElectricReadings();
        return true;
      }
    }
    return false;
  }

  _addNewElectricReading() {
    setState(() {
      _selectedElectricReading = ElectricReading();
    });
    _manageElectricReading();
  }

  _manageElectricReading() async {
    if ((await showElectricReadingManager(context, _selectedElectricReading)) ?? false) _getElectricReadings();
  }

  _getElectricReadings() async {
    var er = await db.getElectricReadings();
    if (this.mounted) {
      setState(() {
        String _current = "";
        _electricReading.clear();
        if (er.length > 0) {
          for (int i = 0; i < er.length; i++) {
            var e = er[i];
            if (_current.isEmpty || _current != (e.person?.name ?? '')) {
              _current = (e.person?.name ?? '');
              e.isHead = true;
              if (i != 0) {
                er[i - 1].isBottom = true;
              }
            }
            _electricReading.add(e);
          }
          _electricReading.last.isBottom = true;
        }
        else{
        _electricReading.clear();
        }
      });
    }
  }
}
