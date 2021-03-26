import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/modals/bills/water_reading_manager.dart';
import 'package:expense_management/modals/delete_record.dart';
import 'package:expense_management/models/bills/water_reading.dart';
import 'package:expense_management/pages/components/custom_dismissible.dart';
import 'package:expense_management/pages/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/helpers/extensions/format_extension.dart';

class WaterReadingManagement extends StatefulWidget {
  @override
  WaterReadingManagementState createState() => WaterReadingManagementState();
}

class WaterReadingManagementState extends State<WaterReadingManagement> {
  MainDB db = MainDB.instance;
  List<WaterReading> _waterReading = [];
  WaterReading _selectedWaterReading = WaterReading();

  @override
  void initState() {
    super.initState();
    _getWaterReadings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('Water Readings')),
            IconButton(icon: Icon(Icons.add), onPressed: _addNewWaterReading),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _waterReading.length,
        itemBuilder: (context, index) {
          return CustomDismissible(
              isTop: _waterReading[index].isHead,
              isBottom: _waterReading[index].isBottom,
              header: _waterReading[index].person?.name ?? '',
              id: _waterReading[index].id.toString(),
              child: ListTile(
                title: Container(
                    child: Row(
                  children: [
                    Expanded(child: Text(_waterReading[index].date.format(dateOnly: true), style: cardTitleStyle2))
                  ],
                )),
                subtitle: Text(_waterReading[index].createdOn.formatLocalize()),
                trailing: Text(
                  _waterReading[index].reading.toString(),
                  style: TextStyle(fontSize: 15),
                ),
              ),
              onDelete: () async {
                return await _deleteWaterReading(_waterReading[index]) ?? false;
              },
              onEdit: () async {
                setState(() {
                  _selectedWaterReading = _waterReading[index];
                });
                _manageWaterReading();
                return false;
              });
        },
      ),
    );
  }

  Future<bool?> _deleteWaterReading(WaterReading obj) async {
    if ((await showDeleteRecordManager(context, "Deleting", "Do you want to delete reading for ${obj.date.format(dateOnly: true)}?")) ?? false) {
      if ((await db.deleteWaterReading(obj.id ?? 0)) > 0) {
        await _getWaterReadings();
        return true;
      }
    }
    return false;
  }

  _addNewWaterReading() {
    setState(() {
      _selectedWaterReading = WaterReading();
    });
    _manageWaterReading();
  }

  _manageWaterReading() async {
    if ((await showWaterReadingManager(context, _selectedWaterReading)) ?? false) _getWaterReadings();
  }

  _getWaterReadings() async {
    var wr = await db.getWaterReadings();
    if (this.mounted) {
      setState(() {
        String _current = "";
        _waterReading.clear();
        if (wr.length > 0) {
          for (int i = 0; i < wr.length; i++) {
            var e = wr[i];
            if (_current.isEmpty || _current != (e.person?.name ?? '')) {
              _current = (e.person?.name ?? '');
              e.isHead = true;
              if (i != 0) {
                wr[i - 1].isBottom = true;
              }
            }
            _waterReading.add(e);
          }
          _waterReading.last.isBottom = true;
        }
      });
    }
  }
}
