import 'package:expense_management/databases/main_db.dart';
import 'package:expense_management/models/bills/electric_reading.dart';
import 'package:expense_management/models/bills/person.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/modals/modal_base.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:expense_management/helpers/extensions/format_extension.dart';

Future<bool?> showElectricReadingManager(context, electricReading) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return ElectricReadingManager(electricReading);
    },
  );
}

class ElectricReadingManager extends StatefulWidget {
  final ElectricReading electricReading;

  const ElectricReadingManager(this.electricReading);

  @override
  State<StatefulWidget> createState() {
    return ElectricReadingManagerState();
  }
}

class ElectricReadingManagerState extends State<ElectricReadingManager> {
  final MainDB db = MainDB.instance;

  ElectricReading _electricReading = ElectricReading();

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
      _electricReading = widget.electricReading;
      _ctrlDate.text = _electricReading.date.format(dateOnly: true);
      _ctrlReading.text = _electricReading.reading.toString();
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
                value: _electricReading.personId,
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
                    _electricReading.reading = int.parse(value);
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
          Expanded(
            child: TextButton(onPressed: _saveElectricReading, child: Text(_electricReading.id == null ? 'Insert' : 'Update')),
          )
        ],
        header: "Manage Electric Reading");
  }

  _selectItem(int? personId) {
    setState(() {
      _electricReading.personId = personId;
      _electricReading.person =
          _persons.where((element) => element.id == personId).first;
    });
  }

  _getDate() async {
    var date = await showDatePicker(context: context, initialDate: _electricReading.date, firstDate: _firstDate, lastDate: _lastDate);
    if (date != null) {
      setState(() {
        _electricReading.date = date;
        _ctrlDate.text = _electricReading.date.format(dateOnly: true);
      });
    }
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
      _electricReading = ElectricReading();
      _ctrlDate.clear();
      _ctrlReading.clear();
    });
    Navigator.of(context).pop(false);
  }

  _saveElectricReading() async {
    try {
      if (_electricReading.id == null)
        await db.insertElectricReading(_electricReading);
      else
        await db.updateElectricReading(_electricReading);
      setState(() {
        _electricReading = ElectricReading();
        _ctrlDate.clear();
        _ctrlReading.clear();
      });
      Navigator.of(context).pop(true);
    } catch (_) {
      Fluttertoast.showToast(msg: "Unable to ${_electricReading.id == null ? 'insert' : 'update'} electric reading");
    }
  }
}
