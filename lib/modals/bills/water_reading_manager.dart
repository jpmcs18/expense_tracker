import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/models/bills/person.dart';
import 'package:expense_management/models/bills/water_reading.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/modals/modal_base.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:expense_management/helpers/extensions/format_extension.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

Future<bool?> showWaterReadingManager(context, waterReading) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return WaterReadingManager(waterReading);
    },
  );
}

class WaterReadingManager extends StatefulWidget {
  final WaterReading waterReading;

  const WaterReadingManager(this.waterReading);

  @override
  State<StatefulWidget> createState() {
    return WaterReadingManagerState();
  }
}

class WaterReadingManagerState extends State<WaterReadingManager> {
  final MainDB db = MainDB.instance;

  WaterReading _waterReading = WaterReading();

  final List<DropdownMenuItem<int>> _dropDownItems = [];
  final List<Person> _persons = [];
  final DateTime _firstDate = DateTime(DateTime.now().year - 1);
  final DateTime _lastDate = DateTime.now();
  final _ctrlDate = TextEditingController();
  final _ctrlReading = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _waterReading = widget.waterReading;
      _ctrlDate.text = _waterReading.date.formatToMonthYear();
      _ctrlReading.text = _waterReading.reading.toString();
    });
    _initStateAsync();
  }

  @override
  Widget build(BuildContext context) {
    return generateModalBody(
        Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                items: _dropDownItems,
                value: _waterReading.personId,
                onChanged: _selectItem,
                isExpanded: true,
                decoration: InputDecoration(labelText: 'Person'),
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
                decoration: InputDecoration(labelText: 'Reading'),
                controller: _ctrlReading,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _waterReading.reading = int.parse(value);
                  });
                },
              ),
            ],
          ),
        ),
        [
          Expanded(
              child: TextButton(onPressed: _cancel, child: Text('Cancel'))),
          VerticalDivider(
            thickness: 1.5,
            indent: 7,
            endIndent: 7,
          ),
          Expanded(
            child: TextButton(
                onPressed: _saveWaterReading,
                child: Text(_waterReading.id == null ? 'Insert' : 'Update')),
          )
        ],
        header: "Manage Water Reading");
  }

  _selectItem(int? personId) {
    setState(() {
      _waterReading.personId = personId;
      _waterReading.person =
          _persons.where((element) => element.id == personId).first;
    });
  }

  _getDate() async {
    showMonthPicker(
      context: context,
      firstDate: _firstDate,
      lastDate: _lastDate,
      initialDate: _waterReading.date,
      locale: Locale("en"),
    ).then((date) async {
      if (date != null) {
        setState(() {
          _waterReading.date = date;
          _ctrlDate.text = _waterReading.date.formatToMonthYear();
        });
      }
    });
  }

  _initStateAsync() async {
    await _getPersons();
    await _setItemToDropDownItems();
  }

  _getPersons() async {
    var persons = await db.getPersons();
    setState(() {
      _persons.clear();
      _persons.addAll(persons);
    });
  }

  _setItemToDropDownItems() async {
    List<DropdownMenuItem<int>> dditem = [];
    for (var item in _persons) {
      dditem.add(DropdownMenuItem(
        child: Text(item.name ?? ''),
        value: item.id,
      ));
    }

    setState(() {
      _dropDownItems.clear();
      _dropDownItems.addAll(dditem);
    });
  }

  _cancel() {
    setState(() {
      _waterReading = WaterReading();
      _ctrlDate.clear();
      _ctrlReading.clear();
    });
    Navigator.of(context).pop(false);
  }

  _saveWaterReading() async {
    try {
      if (_waterReading.id == null)
        await db.insertWaterReading(_waterReading);
      else
        await db.updateWaterReading(_waterReading);
      setState(() {
        _waterReading = WaterReading();
        _ctrlDate.clear();
        _ctrlReading.clear();
      });
      Navigator.of(context).pop(true);
    } catch (_) {
      Fluttertoast.showToast(
          msg:
              "Unable to ${_waterReading.id == null ? 'insert' : 'update'} Water reading");
    }
  }
}
